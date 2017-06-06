class Partygoer < ApplicationRecord
  belongs_to :participant, class_name: "User", foreign_key: "partygoer_id"
  belongs_to :reservation

  validates_uniqueness_of :partygoer_id, scope: :reservation_id
end
