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

  # def amount_pending
  #   amount_that_is_pending = 0
  #   bills.each do |bill|
  #     if bill.status == "pending"
  #       amount_that_is_pending += bill.amount
  #     end
  #   end
  #   amount_that_is_pending
  # end

  # def amount_submitted
  #   amount_that_is_submitted = 0
  #   bills.each do |bill|
  #     if bill.status == "submitted"
  #       amount_that_is_submitted += bill.amount
  #     end
  #   end
  #   amount_that_is_submitted
  # end

  # def amount_paid
  #   amount_that_is_paid = 0
  #   bills.each do |bill|
  #     if bill.status == "paid"
  #       amount_that_is_paid += bill.amount
  #     end
  #   end
  #   amount_that_is_paid
  # end

end
