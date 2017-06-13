class Reservation < ApplicationRecord
  belongs_to :reservation_owner, class_name: "User", foreign_key: "reservation_owner_id"
  has_many :res_tables, dependent: :destroy
  has_many :tables, through: :res_tables
  has_many :partygoers, dependent: :destroy
  has_many :participants, through: :partygoers
  has_many :comments, dependent: :destroy

  has_secure_token

  validates :capacity, presence: true, numericality: true
  validates :date, presence: true
  validates :reservation_owner_id, presence: true, numericality: true

end
