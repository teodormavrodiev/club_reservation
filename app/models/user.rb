class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :omniauthable, omniauth_providers: [:facebook]

  has_many :clubs, foreign_key: "club_owner_id", dependent: :destroy
  has_many :reservations_as_owner, foreign_key: "reservation_owner_id", class_name: "Reservation", dependent: :destroy
  has_many :partygoers, foreign_key: "partygoer_id", dependent: :destroy
  has_many :reservations_as_participant, through: :partygoers, source: :reservation
  has_many :comments, dependent: :destroy
  has_many :ratings, dependent: :destroy

  has_attachment :photo

  validates :email, presence: true, format: { with: Devise::email_regexp }
  validates :full_name, presence: true


  def self.find_for_facebook_oauth(auth)
    user_params = auth.slice(:provider, :uid)
    user_params.merge! auth.info.slice(:email, :first_name, :last_name)
    user_params[:facebook_picture_url] = auth.info.image
    user_params[:token] = auth.credentials.token
    user_params[:token_expiry] = Time.at(auth.credentials.expires_at)
    user_params[:full_name] = user_params[:first_name] + " " + user_params[:last_name]
    user_params = user_params.to_h

    user = User.find_by(provider: auth.provider, uid: auth.uid)
    user ||= User.find_by(email: auth.info.email) # User did a regular sign up in the past.
    if user
      user.update(user_params.except("first_name", "last_name"))
    else
      user = User.new(user_params.except("first_name", "last_name"))
      user.photo_url = auth.info.image
      user.password = Devise.friendly_token[0,20]  # Fake password for validation
      user.save
    end

    return user
  end
end
