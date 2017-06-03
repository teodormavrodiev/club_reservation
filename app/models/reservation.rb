class Reservation < ApplicationRecord
  belongs_to :reservation_owner, class_name: "User", foreign_key: "reservation_owner_id"
  belongs_to :table
  has_many :partygoers, dependent: :destroy
  has_many :participants, through: :partygoers
  has_many :comments, dependent: :destroy
end
