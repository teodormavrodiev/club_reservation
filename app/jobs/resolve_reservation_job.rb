class ResolveReservationJob < ApplicationJob
  queue_as :default

  def perform(reservation_id)
    reservation = Reservation.find(reservation_id)
    unless reservation.kaparo_paid
      if reservation.seconds_since_creation > 5400
        #Hour and 30 minutes has passed since creation. Just void reservation completely and inform owner.
        owner = reservation.reservation_owner
        reservation.bills.each do |bill|
          bill.void if bill.status != "unsent"
          bill.destroy!
        end
        ReservationMailer.reservation_cancelled(reservation.id).deliver_now
        reservation.destroy!
      else
        result = reservation.pay_split_bills
        if result == "Can't split bills, because money wasn't collected"
          owner = reservation.reservation_owner
          reservation.bills.each do |bill|
            bill.void if bill.status != "unsent"
            bill.destroy!
          end
          ReservationMailer.reservation_cancelled(reservation.id).deliver_now
          reservation.destroy!
        end
      end
    end
  end
end
