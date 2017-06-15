class CommentMailer < ApplicationMailer

  def new_comment(comment_id)
    @comment = Comment.find(comment_id)
    @comment_owner = @comment.user
    @reservation = @comment.reservation
    club_name = @reservation.tables.first.club.name

    #mail to owner of reservation

    mail(to: @reservation.reservation_owner.email, subject: 'New Comment for reservation in #{club_name}') unless @reservation.reservation_owner == @comment_owner

    #mail to participants in reservation

    @reservation.participants.each do |par|
      mail(to: par.email, subject: "New Comment for reservation in #{club_name}") unless par == @comment_owner
    end
  end

end
