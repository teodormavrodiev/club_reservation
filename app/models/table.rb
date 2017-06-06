class Table < ApplicationRecord
  belongs_to :club
  has_many :res_tables
  has_many :reservations, through: :res_tables, dependent: :destroy

  validates :capacity, presence: true, numericality: true
  validates :club_id, presence: true, numericality: true

  def reserved_on?(date)
    if reservations.where(date:date).exists?
      true
    else
      false
    end
  end
end
