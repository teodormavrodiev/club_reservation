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
        return redirect_to :back, notice: "Table is already reserved."
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
      ResolveReservationJob.set(wait: 60.minutes).perform_later(res.id)
      return redirect_to reservation_path(res, token: res.token), alert: "We have saved the table/s for you. Unfortunately, this club requires a Kaparo. This reservation will expire in one hour, unless you pay the kaparo. See available payment methods below."
    else
      res.participants.each do |user|
        ReservationMailer.reservation_confirmed(res.id, user.id).deliver_later
      end
      ReservationMailer.reservation_confirmed(res.id, res.reservation_owner.id).deliver_later
      return redirect_to reservation_path(res, token: res.token), notice: "Successfully reserved."
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

  def invite_with_sms
    @reservation = Reservation.find(params[:id])
    if params[:token] == @reservation.token
      authorize @reservation
    else
      raise
      #create a custom error for this
    end
  end

  def invite_with_twilio
    @reservation = Reservation.find(params[:id])
    if params[:token] == @reservation.token
      authorize @reservation
    else
      raise
      #create a custom error for this
    end

    number = params[:number]
    status = @reservation.send_sms_invitation_to_number(number, current_user)

    if status == true
      render json: @reservation, status: :ok
    else
      render json: @reservation, status: :fail
    end
  end

  def pay_all_now
    pay
  end

  def pay_with_split
    pay
  end

  def pay
    Braintree::Configuration.environment = :sandbox
    Braintree::Configuration.merchant_id = ENV["BRAINTREE_MERCHANT_ID"]
    Braintree::Configuration.public_key = ENV["BRAINTREE_PUBLIC_KEY"]
    Braintree::Configuration.private_key = ENV["BRAINTREE_PRIVATE_KEY"]

    begin
      customer = Braintree::Customer.find(current_user.braintree_id)
    rescue
      customer = Braintree::Customer.create(id: current_user.braintree_id)
    end

    current_user.authorize_unsent_bills

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

    @reservation.bills.last.submit_for_settlement

    if @reservation.bills.last.status == "submitted_for_settlement"
      @reservation.bills.last.send_email_confirmation_after_submitted
      @reservation.cleanse_unsent_or_authorized_bills_when_paying_in_full
      @reservation.kaparo_paid = true
      @reservation.save!
      @reservation.participants.each do |user|
        ReservationMailer.reservation_confirmed(@reservation.id, user.id).deliver_later
      end
      ReservationMailer.reservation_confirmed(@reservation.id, @reservation.reservation_owner.id).deliver_later
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

    if @reservation.participants.include?(current_user)
      ReservationMailer.recently_joined_to_owner(@reservation.id, current_user.id).deliver_later
      ReservationMailer.confirmation_for_joining(@reservation.id, current_user.id).deliver_later

      redirect_to reservation_path(@reservation, token: @reservation.token), notice: "Successfully joined reservation."
    else
      redirect_to reservation_path(@reservation, token: @reservation.token), alert: "There was an error, please try again."
    end
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
