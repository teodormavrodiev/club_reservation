class ReservationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show]

  def index
    @owner_of = policy_scope(Reservation).where(reservation_owner: current_user)
    @participant_in = current_user.reservations_as_participant
  end

  def create
    #create a new reservation with the params
    # CONVERT THIS TO A POST WHEN YOU ARE DONE WITH FUNCTIONALITY !!!

    arr = []
    params.each do |par|
      arr << par if par.include?("table")
    end
    res_capacity = 0
    res_date = Date.today
    res_tables = []
    arr.length.times do |i|
      table_number_string = arr[i]
      table_to_reserve = Table.find(table_number_string.gsub("table", "").to_i)
      res_capacity += table_to_reserve.capacity
      res_tables << table_to_reserve
    end
    res = Reservation.new({
      capacity: res_capacity,
      date: res_date
      })
    res.tables = res_tables
    res.reservation_owner = current_user

    kaparo_required = false

    res.tables.each do |table|
      if table.reserved_on?(res_date)
        authorize res
        redirect_to :back, notice: "Table is already reserved."
      end
      if table.kaparo_required
        kaparo_required = true
      end
    end

    authorize res

    if kaparo_required == true
      res.kaparo_paid = false
    else
      res.kaparo_paid = true
    end

    res.save!

    if kaparo_required
      ResolveReservationJob.set(wait:60.minutes).perform_later(res.id)
      redirect_to reservation_path(res, token: res.token), alert: "We have saved the table/s for you. Unfortunately, this club requires a Kaparo. This reservation will expire in one hour, unless you pay the kaparo. See available payment methods below."
    else
      redirect_to reservation_path(res, token: res.token), notice: "Successfully reserved."
    end


  end

  def show
    @reservation = Reservation.find(params[:id])
    if params[:token] == @reservation.token
      authorize @reservation
    else
      raise
      #create a custom error for this
    end
  end

  def pay_all_now
    Braintree::Configuration.environment = :sandbox
    Braintree::Configuration.merchant_id = ENV["BRAINTREE_MERCHANT_ID"]
    Braintree::Configuration.public_key = ENV["BRAINTREE_PUBLIC_KEY"]
    Braintree::Configuration.private_key = ENV["BRAINTREE_PRIVATE_KEY"]

    begin
      customer = Braintree::Customer.find(current_user.braintree_id)
    rescue
      customer = Braintree::Customer.create(id: current_user.braintree_id)
    end

    @braintree_token = Braintree::ClientToken.generate(customer_id: current_user.braintree_id)

    @reservation = Reservation.find(params[:id])
    if params[:token] == @reservation.token
      authorize @reservation
    else
      raise
      #create a custom error for this
    end
  end

  def receive_nonce_and_pay
    @reservation = Reservation.find(params[:id])
    authorize @reservation

    nonce_from_the_client = params[:payment_method_nonce]

    bill = Bill.create(user: current_user, reservation: @reservation, status: :unsent, amount: @reservation.full_amount_to_be_payed.to_f, one_time_nonce: nonce_from_the_client)

    @reservation.bills.first.submit_for_settlement

    if @reservation.bills.first.status == "submitted_for_settlement"
      @reservation.kaparo_paid = true
      @reservation.save!
    end

  end

  def pay_with_split
    Braintree::Configuration.environment = :sandbox
    Braintree::Configuration.merchant_id = ENV["BRAINTREE_MERCHANT_ID"]
    Braintree::Configuration.public_key = ENV["BRAINTREE_PUBLIC_KEY"]
    Braintree::Configuration.private_key = ENV["BRAINTREE_PRIVATE_KEY"]

    begin
      customer = Braintree::Customer.find(current_user.braintree_id)
    rescue
      customer = Braintree::Customer.create(id: current_user.braintree_id)
    end

    @braintree_token = Braintree::ClientToken.generate(customer_id: current_user.braintree_id)

    @reservation = Reservation.find(params[:id])
    if params[:token] == @reservation.token
      authorize @reservation
    else
      raise
      #create a custom error for this
    end

  end

  def receive_nonce_and_create_unsent_bill
    @reservation = Reservation.find(params[:id])
    authorize @reservation

    nonce_from_the_client = params[:payment_method_nonce]
    payment_amount = params[:payment_amount]

    bill = Bill.create(user: current_user, reservation: @reservation, status: :unsent, amount: payment_amount.to_f, one_time_nonce: nonce_from_the_client)
  end

  def pay_all_split_fees
    @reservation = Reservation.find(params[:id])
    if params[:token] == @reservation.token
      authorize @reservation
    else
      raise
      #create a custom error
    end

    notice_message = @reservation.pay_split_bills
    redirect_to reservation_path(@reservation, token: @reservation.token), notice: notice_message
  end

  def join
    @reservation = Reservation.find(params[:id])
    authorize @reservation

    @reservation.participants << current_user

    #send mail to res_owner

    ReservationMailer.recently_joined_to_owner(@reservation.id, current_user).deliver_now

    #send mail to participants

    @reservation.participants.each do |par|
      ReservationMailer.recently_joined_to_participant(@reservation.id, par, current_user).deliver_now unless par == current_user
    end

    #send mail to user

    ReservationMailer.confirmation(@reservation.id, current_user).deliver_now

    redirect_to reservation_path(@reservation, token: @reservation.token), notice: "Successfully joined reservation."
  end

  def leave
    reservation = Reservation.find(params[:id])
    authorize reservation

    reservation.participants.destroy(current_user)
    redirect_to reservations_path
  end

  def cancel
    reservation = Reservation.find(params[:id])
    authorize reservation

    reservation.destroy
    redirect_to reservations_path
  end

end
