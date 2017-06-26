class CommentMailer < ApplicationMailer

  def new_comment_to_owner(comment_id)
    @comment = Comment.find(comment_id)
    @reservation = @comment.reservation
    @club_name = @reservation.tables.first.club.name

    #mail to owner of reservation

    mail(to: @reservation.reservation_owner.email, subject: "New Comment for reservation in #{@club_name} on the #{@reservation.date}")

  end

  def new_comment_to_participant(comment_id, par_id)
    @comment = Comment.find(comment_id)
    @reservation = @comment.reservation
    @club_name = @reservation.tables.first.club.name
    @participant = User.find(par_id)

    mail(to: @participant.email, subject: "New Comment for reservation in #{@club_name} on the #{@reservation.date}")
  end

end
