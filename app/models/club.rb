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

  def average_rating
    average_rating = 0
    self.ratings.each do |rating|
      average_rating += rating.score
    end
    average_rating/self.ratings.length
  end

  def votes
    self.ratings.length
  end

  def seats_available
    seats_left = self.capacity
    self.tables.each do |table|
      if table.reserved?
        seats_left -= table.capacity
      end
    end
    seats_left
  end

end
