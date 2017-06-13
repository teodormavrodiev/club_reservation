class ReservationsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:invited_friends]

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

  def invited_friends
    reservation = Reservation.find(params[:id])
    authorize reservation

  end

  def join

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
