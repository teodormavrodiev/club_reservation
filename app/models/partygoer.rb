class Partygoer < ApplicationRecord
  belongs_to :participant, class_name: "User", foreign_key: "partygoer_id"
  belongs_to :reservation

  validates :partygoer_id, presence: true, numericality: true
  validates :reservation_id, presence: true, numericality: true
  validates_uniqueness_of :partygoer_id, scope: :reservation_id
end
