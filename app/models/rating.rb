class Rating < ApplicationRecord
  belongs_to :club
  belongs_to :user

  validates :score, numericality: true, presence: true
  validates :club_id, presence: true, numericality: true
  validates :user_id, presence: true, numericality: true
end
