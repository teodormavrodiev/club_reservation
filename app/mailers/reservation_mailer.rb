class ReservationMailer < ApplicationMailer

  def recently_joined(reservation_id)
    @reservation = Reservation.find(reservation_id)
    @last_joined_user = @reservation.participants.last
    club_name = @reservation.tables.first.club.name

    #mail to reservation owner

    mail(to: @reservation.reservation_owner.email, subject: 'Welcome to TheTable')

    #mail to participants

    @reservation.participants.each do |par|
      mail(to: par.email, subject: "#{@last_joined_user.full_name} joined your reservation in #{club_name}") unless par == @last_joined_user
    end

  end

  def confirmation(reservation_id)
    @reservation = Reservation.find(reservation_id)
    @last_joined_user = @reservation.participants.last
    club_name = @reservation.tables.first.club.name

    mail(to: @last_joined_user.email, subject: "Confirmation for your reservation in #{club_name}")
  end

end
