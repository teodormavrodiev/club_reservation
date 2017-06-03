class Club < ApplicationRecord
  belongs_to :club_owner, class_name: "User", foreign_key: "club_owner_id"
  has_many :tables, dependent: :destroy
  has_many :reservations, through: :tables
  has_many :ratings, dependent: :destroy

  validates :name, presence: true
  validates :capacity, numericality: true
  validates :description, presence: true
  validates :location, presence: true
  validates :club_owner_id, presence: true, numericality: true
end
