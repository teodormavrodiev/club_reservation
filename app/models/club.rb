class Club < ApplicationRecord
  belongs_to :club_owner, class_name: "User", foreign_key: "club_owner_id"
  has_many :tables, dependent: :destroy
  has_many :reservations, through: :tables
  has_many :ratings, dependent: :destroy

  has_attachments :photos, maximum: 20

  geocoded_by :location

  validates :name, presence: true
  validates :capacity, numericality: true
  validates :description, presence: true
  validates :location, presence: true
  validates :club_owner_id, presence: true, numericality: true

  after_validation :geocode, if: :location_changed?

  scope :has_free_seats_on, -> (date, clubs) {
    filtered_clubs = []
    clubs.each do |club|
      if club.seats_available_on(date) > 0
        filtered_clubs << club
      end
    end
    return filtered_clubs
  }

  scope :is_in, -> (region, clubs) {
    filtered_clubs = []
    clubs.each do |club|
      if club.region == region
        filtered_clubs << club
      end
    end
    return filtered_clubs
  }

  def average_rating
    average_rating = 0
    if votes > 0
      ratings.each do |rating|
        average_rating += rating.score
      end
      average_rating = average_rating/votes
    else
      average_rating = "Not enough votes"
    end
    average_rating
  end

  def votes
    ratings.length
  end

  def seats_available_on(date)
    seats_left = capacity
    tables.each do |table|
      if table.reserved_on?(date)
        seats_left -= table.capacity
      end
    end
    seats_left
  end

end
