class Table < ApplicationRecord
  belongs_to :club
  has_many :reservations, dependent: :destroy
end
