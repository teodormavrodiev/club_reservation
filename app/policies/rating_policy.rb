class RatingPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def new?
    user.ratings.where(club_id:record.club_id).empty?
  end

  def create?
    user.ratings.where(club_id:record.club_id).empty?
  end
end
