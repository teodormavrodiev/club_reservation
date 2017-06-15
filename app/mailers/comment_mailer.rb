class CommentMailer < ApplicationMailer

  def new_comment_to_owner(comment_id)
    @comment = Comment.find(comment_id)
    @reservation = @comment.reservation
    club_name = @reservation.tables.first.club.name

    #mail to owner of reservation

    mail(to: @reservation.reservation_owner.email, subject: 'New Comment for reservation in #{club_name}')

  end

  def new_comment_to_participant(comment_id, par)
    @comment = Comment.find(comment_id)
    @reservation = @comment.reservation
    club_name = @reservation.tables.first.club.name

    mail(to: par.email, subject: "New Comment for reservation in #{club_name}")
  end

end
