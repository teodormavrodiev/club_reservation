class ReservationMailer < ApplicationMailer

  def recently_joined_to_owner(reservation_id, just_joined)
    @reservation = Reservation.find(reservation_id)
    club_name = @reservation.tables.first.club.name

    #mail to reservation owner

    mail(to: @reservation.reservation_owner.email, subject: "#{just_joined.full_name} joined your reservation in #{club_name}")

  end

  def recently_joined_to_participant(reservation_id, par, just_joined)
    @reservation = Reservation.find(reservation_id)
    club_name = @reservation.tables.first.club.name

    mail(to: par.email, subject: "#{just_joined.full_name} joined your reservation in #{club_name}")

  end


  def confirmation(reservation_id, just_joined)
    @reservation = Reservation.find(reservation_id)
    club_name = @reservation.tables.first.club.name

    mail(to: just_joined.email, subject: "Confirmation for your reservation in #{club_name}")
  end

  def reservation_voided(reservation_id)

  end

end
