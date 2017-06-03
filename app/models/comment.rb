class Comment < ApplicationRecord
  belongs_to :reservation
  belongs_to :user

  validates :information, presence: true
  validates :datetime, presence: true
  validates :user_id, presence: true, numericality: true
  validates :reservation_id, presence: true, numericality: true
end
