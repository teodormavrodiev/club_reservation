class Comment < ApplicationRecord
  belongs_to :reservation
  belongs_to :user

  validates :information, presence: true
  validates :datetime, presence: true
  validates :user_id, presence: true, numericality: true
  validates :reservation_id, presence: true, numericality: true

  after_create :send_new_comment_mail


  private

  def send_new_comment_mail
    CommentMailer.new_comment(self.id).deliver_now
  end
end
