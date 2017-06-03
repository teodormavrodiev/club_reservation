class Table < ApplicationRecord
  belongs_to :club
  has_many :reservations, dependent: :destroy

  validates :capacity, presence: true, numericality: true
  validates :club_id, presence: true, numericality: true
end
