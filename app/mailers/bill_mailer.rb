class BillMailer < ApplicationMailer

  def bill_failed_to_void(transaction_id)
    @transaction_id = transaction_id

    mail(to: "teodor.mavrodiev@gmail.com", subject: "Bill failed to void.")
  end

  def bill_failed_to_refund(transaction_id)
    @transaction_id = transaction_id

    mail(to: "teodor.mavrodiev@gmail.com", subject: "Bill failed to refund.")
  end

  def bill_submitted_successfully(bill_id)
    @bill = Bill.find(bill_id)
    @owner = @bill.user
    @reservation = @bill.reservation
    @club_name = @reservation.tables.first.club.name

    mail(to: @owner.email, subject: "Successfull payment to TheTable for reservation in #{@club_name}")
  end

  def reservation_bill_failure_to_settle(bill_id, time_to_respond)
    @bill = Bill.find(bill_id)
    @owner = @bill.user
    @reservation = @bill.reservation
    @time_to_respond = time_to_respond
    @club_name = @reservation.tables.first.club.name

    mail(to: @owner.email, subject: "Bill failed. Please try a different method. #{@time_to_respond} minutes left before reservation is cancelled..")
  end

  def reservation_bill_failure_to_authorize(bill_id, time_to_respond)
    @bill = Bill.find(bill_id)
    @owner = @bill.user
    @reservation = @bill.reservation
    @time_to_respond = time_to_respond
    @club_name = @reservation.tables.first.club.name

    mail(to: @owner.email, subject: "Bill failed. Please try a different method. #{@time_to_respond} minutes left before reservation is cancelled..")
  end

  def user_bill_failure_to_authorize(bill_id)
    @bill = Bill.find(bill_id)
    @owner = @bill.user
    @reservation = @bill.reservation
    @club_name = @reservation.tables.first.club.name

    mail(to: @owner.email, subject: "Bill failed. Please try a different method.")
  end
end
