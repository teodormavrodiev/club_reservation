class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :clubs, foreign_key: "club_owner_id", dependent: :destroy
  has_many :reservations_as_owner, foreign_key: "reservation_owner_id", class_name: "Reservation", dependent: :destroy
  has_many :partygoers, foreign_key: "partygoer_id", dependent: :destroy
  has_many :reservations_as_participant, through: :partygoers, source: :reservation
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy

  validates :email, presence: true, format: { with: Devise::email_regexp }
  # validates :full_name, presence: true
end
