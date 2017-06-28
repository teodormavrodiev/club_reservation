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

  def show?
    true
  end

  def join?
    !record.participants.include?(user)
  end

  def pay_all_now?
    true
  end

  def receive_nonce_and_pay?
    true
  end

  def pay_with_split?
    true
  end

  def receive_nonce_and_create_unsent_bill?
    true
  end

  def pay_all_split_fees?
    true
  end

  def invite_with_sms?
    true
  end

  def invite_with_twilio?
    true
  end

end
