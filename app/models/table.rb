class Table < ApplicationRecord
  belongs_to :club
  has_many :res_tables, dependent: :destroy
  has_many :reservations, through: :res_tables, dependent: :destroy

  validates :capacity, presence: true, numericality: true
  validates :club_id, presence: true, numericality: true

  def reserved?
    #return true if reserved
  end
end
