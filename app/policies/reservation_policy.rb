class ReservationPolicy < ApplicationPolicy
  class Scope < Scope
    def resolve
      scope.all
    end
  end

  def create?
    true
  end

  def leave?
    record.participants.include?(user)
  end

  def cancel?
    record.reservation_owner == user
  end
end
