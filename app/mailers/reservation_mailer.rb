class ReservationMailer < ApplicationMailer

  def recently_joined_to_owner(reservation_id, just_joined_id)
    @reservation = Reservation.find(reservation_id)
    @club_name = @reservation.tables.first.club.name
    @user = User.find(just_joined_id)

    mail(to: @reservation.reservation_owner.email, subject: "#{@user.full_name} joined your reservation in #{@club_name}")
  end


  def confirmation_for_joining(reservation_id, just_joined_id)
    @reservation = Reservation.find(reservation_id)
    @club_name = @reservation.tables.first.club.name
    @user = User.find(just_joined_id)

    mail(to: @user.email, subject: "Confirmation for joining the reservation in #{@club_name}")
  end

  def reservation_cancelled(reservation_id)
    @reservation = Reservation.find(reservation_id)
    @club_name = @reservation.tables.first.club.name

    mail(to: @reservation.reservation_owner.email, subject: "Your reservation to #{@club_name} has been cancelled.")
  end

  def reservation_confirmed(reservation_id, user_id)
    @reservation = Reservation.find(reservation_id)
    @club_name = @reservation.tables.first.club.name
    @user = User.find(user_id)

    mail(to: @user.email, subject: "Your reservation to #{@club_name} has been confirmed.")
  end

end
