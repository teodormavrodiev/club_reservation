class ReservationMailer < ApplicationMailer

  def recently_joined_to_owner(reservation_id)
    @reservation = Reservation.find(reservation_id)
    @last_joined_user = @reservation.participants.last
    club_name = @reservation.tables.first.club.name

    #mail to reservation owner

    mail(to: @reservation.reservation_owner.email, subject: '#{@last_joined_user.full_name} joined your reservation in #{club_name}')

  end

  def recently_joined_to_participant(reservation_id, par)
    @reservation = Reservation.find(reservation_id)
    @last_joined_user = @reservation.participants.last
    club_name = @reservation.tables.first.club.name

    mail(to: par.email, subject: "#{@last_joined_user.full_name} joined your reservation in #{club_name}")

  end


  def confirmation(reservation_id)
    @reservation = Reservation.find(reservation_id)
    @last_joined_user = @reservation.participants.last
    club_name = @reservation.tables.first.club.name

    mail(to: @last_joined_user.email, subject: "Confirmation for your reservation in #{club_name}")
  end

end
