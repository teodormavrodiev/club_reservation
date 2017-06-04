class ReservationsController < ApplicationController

  def index
    @owner_of = current_user.reservations_as_owner
    @participant_in = current_user.reservations_as_participant
  end

  def show

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
    res.save!
    redirect_to reservations_path
  end

  def invite_friends

  end

  def join

  end

  def leave

  end

  def show_comments

  end

  def cancel

  end

end
