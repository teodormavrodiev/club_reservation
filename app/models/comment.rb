class Comment < ApplicationRecord
  belongs_to :reservation
  belongs_to :user
end
