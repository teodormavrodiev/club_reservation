class Comment < ApplicationRecord
  belongs_to :reservation
  belongs_to :user

  validates :information, presence: true
  validates :datetime, presence: true
  validates :user_id, presence: true, numericality: true
  validates :reservation_id, presence: true, numericality: true

  after_create :send_new_comment_mails


  private

  def send_new_comment_mails
    #send to owner
    CommentMailer.new_comment_to_owner(self.id).deliver_later unless self.user == self.reservation.reservation_owner

    #send to participants
    self.reservation.participants.each do |par|
      CommentMailer.new_comment_to_participant(self.id, par.id).deliver_later unless self.user == par
    end

  end
end
