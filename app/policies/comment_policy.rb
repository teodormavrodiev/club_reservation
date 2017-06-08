class CommentPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope
    end
  end

  def create?
    record.reservation.participants.include?(user) || record.reservation.reservation_owner == user
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user || record.reservation.reservation_owner == user
  end

end
