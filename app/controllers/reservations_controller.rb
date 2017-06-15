class ReservationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show_to_invited_friends]

  def index
    @owner_of = policy_scope(Reservation).where(reservation_owner: current_user)
    @participant_in = current_user.reservations_as_participant
  end

  def create
    arr = []
    params.each do |par|
      arr << par if par.include?("table")
    end
    res_capacity = 0
    res_date = Date.today
    res_tables = []
    arr.length.times do |i|
      table_number = arr[i]
      table_to_reserve = Table.find(table_number.gsub("table", "").to_i)
      res_capacity += table_to_reserve.capacity
      res_tables << table_to_reserve
    end
    res = Reservation.new({
      capacity: res_capacity,
      date: res_date
      })
    res.tables = res_tables
    res.reservation_owner = current_user
    save_res = "yes"
    res.tables.each do |table|
      if table.reserved_on?(res_date)
        save_res = "no"
      end
    end

    authorize res

    res.save! if save_res == "yes"
    redirect_to reservations_path
  end

  def show_to_invited_friends
    @reservation = Reservation.find(params[:id])
    if params[:token] == @reservation.token
      authorize @reservation
    else
      raise
      #create a custom error for this
    end
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

    redirect_to reservations_path
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
