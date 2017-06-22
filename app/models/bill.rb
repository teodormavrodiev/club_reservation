class Bill < ApplicationRecord
  belongs_to :user
  belongs_to :reservation

  enum status: [:pending, :submitted, :paid, :rejected]

end
