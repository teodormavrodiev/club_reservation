class Partygoer < ApplicationRecord
  belongs_to :participant, class_name: "User", foreign_key: "partygoer_id"
  belongs_to :reservation
end
