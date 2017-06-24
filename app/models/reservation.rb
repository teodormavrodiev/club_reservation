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

  def amount_unsent
    amount_that_is_unsent = 0
    bills.each do |bill|
      if bill.status == "unsent"
        amount_that_is_unsent += bill.amount
      end
    end
    amount_that_is_unsent
  end

  def pay_split_bills
    if amount_unsent >= full_amount_to_be_payed
      accrue_convenience_fee_on_bills
      authorize_all_bills
      if all_bills_authorized?
        submit_all_bills_for_settlement
        if all_bills_submitted_for_settlement?
          #send success emails to participants
          self.kaparo_paid = true
          self.save!
          return "success"
        else
          #a bill wasn't submitted for settlement, inform the user if it's a click,
          #if it's automatic send an sms to person who didn't get approved and prolong reservation period
          #5 mins to let user switch payment methods
          return "not all submitted"
        end
      else
        #a bill wasn't authorized, inform the user, if it's a click, if it's automatic
        #send an sms to person who didn't get authorized, and prolong reservation period for
        #5 mins to let user switch payment methods
        return "not all authorized"
      end
    else
      #if from a button clicked by a user, tell him money isn't collected.
      #if froma rake task automatically at the time of reservation resolve then
      #sent emails that money wasn't collected in time, so reservation is void
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
      if bill.status != "authorized"
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
      if bill.status != "submitted_for_settlement"
        break false
      end
    end
  end

  def accrue_convenience_fee_on_bills
    bills.each do |bill|
      bill.amount = bill.amount*1.05
      bill.save!
    end
  end

end
