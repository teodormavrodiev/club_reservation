class ResolveReservationJob < ApplicationJob
  queue_as :default

  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)

    if reservation.created_at - DateTime.now < -5400
      #Hour and 30 minutes has passed since creation. Just void reservation completely and inform owner.
      owner = reservation.reservation_owner
      reservation.bills.each do |bill|
        bill.void
        bill.destroy!
      end
      reservation.destroy!
      ReservationMailer.reservation_voided(reservation.id).deliver_later
    else
      result = pay_split_bills
      if result == "Can't split bills, because money wasn't collected"
        owner = reservation.reservation_owner
        reservation.bills.each do |bill|
          bill.void
          bill.destroy!
        end
        reservation.destroy!
        ReservationMailer.reservation_voided(reservation.id).deliver_later
      end
    end
  end
end
