class Reservation < ApplicationRecord
  belongs_to :reservation_owner, class_name: "User", foreign_key: "reservation_owner_id"
  has_many :res_tables, dependent: :destroy
  has_many :tables, through: :res_tables
  has_many :partygoers, dependent: :destroy
  has_many :participants, through: :partygoers
  has_many :comments, dependent: :destroy
  #figure out a way to remove dependent destroy on a reservation
  has_many :bills, dependent: :destroy

  has_secure_token

  validates :capacity, presence: true, numericality: true
  validates :date, presence: true
  validates :reservation_owner_id, presence: true, numericality: true

  def full_amount_to_be_payed
    amount = 0
    tables.each do |table|
      if table.kaparo_required
        amount += table.kaparo_amount
      end
    end
    amount
  end

  def amount_collected
    amount_that_is_collected = 0
    bills.each do |bill|
      if bill.status == "unsent" || bill.status == "authorized"
        amount_that_is_collected += bill.amount / 1.05
      end
    end
    amount_that_is_collected
  end

  def amount_paid
    amount_already_paid = 0
    bills.each do |bill|
      if bill.status == "submitted_for_settlement" || bill.status == "accepted"
        amount_already_paid += bill.amount / 1.05
      end
    end
    amount_already_paid
  end

  def pay_split_bills
    if amount_collected >= full_amount_to_be_payed - amount_paid
      authorize_all_bills
      if all_bills_authorized?
        submit_all_bills_for_settlement
        if all_bills_submitted_for_settlement?
          bills.each do |bill|
            bill.send_email_confirmation_after_submitted
          end
          self.kaparo_paid = true
          self.save!
          return "success"
        else
          bills.authorized.each do |auth_bill|
            if self.seconds_since_creation >= 3600
              ResolveReservationJob.set(wait: 5.minutes).perform_later(self.id)
              user = auth_bill.user
              minutes_left = 5
              auth_bill.send_email_for_failure_of_settlement(minutes_left)
              auth_bill.void
              auth_bill.destroy!
            else
              user = auth_bill.user
              minutes_left = 60 - self.minutes_since_creation
              auth_bill.send_email_for_failure_of_settlement(minutes_left)
              auth_bill.void
              auth_bill.destroy!
            end
          end
          return "not all submitted"
        end
      else
        bills.unsent.each do |unsent_bill|
          if self.seconds_since_creation > 3600
            ResolveReservationJob.set(wait: 5.minutes).perform_later(self.id)
            user = unsent_bill.user
            minutes_left = 5
            unsent_bill.send_email_for_failure_of_authorization(minutes_left)
            unsent_bill.destroy!
          else
            user = unsent_bill.user
            minutes_left = 60 - self.minutes_since_creation
            unsent_bill.send_email_for_failure_of_authorization(minutes_left)
            unsent_bill.destroy!
          end
        end
        return "not all authorized"
      end
    else
      return "Can't split bills, because money wasn't collected"
    end
  end

  def authorize_all_bills
    bills.each do |bill|
      bill.authorize
    end
  end

  def all_bills_authorized?
    bills.each do |bill|
      if bill.status == "unsent"
        break false
      end
    end
  end

  def submit_all_bills_for_settlement
    bills.each do |bill|
      bill.submit_for_settlement
    end
  end

  def all_bills_submitted_for_settlement?
    bills.each do |bill|
      if bill.status == "unsent" || bill.status == "authorized"
        break false
      end
    end
  end

  def seconds_since_creation
    (self.created_at - DateTime.now)*(-1)
  end

  def minutes_since_creation
    ((self.created_at - DateTime.now)*(-1) / 60).round(0)
  end
end
