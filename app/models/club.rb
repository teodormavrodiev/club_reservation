class Club < ApplicationRecord
  belongs_to :club_owner, class_name: "User", foreign_key: "club_owner_id"
  has_many :tables, dependent: :destroy
  has_many :reservations, through: :tables
  has_many :ratings, dependent: :destroy
end
