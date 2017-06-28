require 'twilio-ruby'

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

  def share_contributed_by_user(id)
    user = User.find(id)
    bills = self.bills.where(user: user)
    amount = 0
    bills.each do |bill|
      amount += bill.amount / 1.05
    end
    amount
  end

  def pay_split_bills
    if amount_collected == full_amount_to_be_payed - amount_paid
      authorize_all_bills
      if all_bills_authorized?
        submit_all_bills_for_settlement
        if all_bills_submitted_for_settlement?
          bills.each do |bill|
            bill.send_email_confirmation_after_submitted
          end
          self.kaparo_paid = true
          self.save!
          self.participants.each do |participant|
            ReservationMailer.reservation_confirmed(self.id, participant.id).deliver_later
          end
          ReservationMailer.reservation_confirmed(self.id, self.reservation_owner.id).deliver_later
          return "success"
        else
          bills.authorized.each do |auth_bill|
            if self.seconds_since_creation >= 3600
              ResolveReservationJob.set(wait: 5.minutes).perform_later(self.id)
              user = auth_bill.user
              minutes_left = 5
              BillMailer.reservation_bill_failure_to_settle(auth_bill.id, minutes_left).deliver_now
              auth_bill.void
              auth_bill.destroy!
            else
              user = auth_bill.user
              minutes_left = 60 - self.minutes_since_creation
              BillMailer.reservation_bill_failure_to_settle(auth_bill.id, minutes_left).deliver_now
              auth_bill.void
              auth_bill.destroy!
            end
          end
          return "not all submitted"
        end
      else
        bills.unsent.each do |unsent_bill|
          if self.seconds_since_creation >= 3600
            ResolveReservationJob.set(wait: 5.minutes).perform_later(self.id)
            user = unsent_bill.user
            minutes_left = 5
            BillMailer.reservation_bill_failure_to_authorize(unsent_bill.id, minutes_left).deliver_now
            unsent_bill.destroy!
          else
            user = unsent_bill.user
            minutes_left = 60 - self.minutes_since_creation
            BillMailer.reservation_bill_failure_to_authorize(unsent_bill.id, minutes_left).deliver_now
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

  def cleanse_unsent_or_authorized_bills_when_paying_in_full
    bills.authorized.each do |bill|
      bill.void
      bill.destroy!
    end
    bills.unsent.each do |bill|
      bill.destroy!
    end
  end

  def send_sms_invitation_to_number(number, user)
    club_name = tables.first.club.name
    account_sid = ENV['TWILIO_API_ACCOUNT_SID']
    auth_token = ENV['TWILIO_API_AUTH_TOKEN']

    Twilio.configure do |config|
      config.account_sid = account_sid
      config.auth_token = auth_token
    end

    @client = Twilio::REST::Client.new

    if @client.messages.create(
      from: "+13238005977" ,
      to: "#{number}",
      body: "Hey! Your buddy #{user.full_name}, wants to invite you to a reservation in #{club_name}, on the
      #{date}. Follow this link to accept his invitation and coordinate with your friends. #{Rails.application.routes.url_helpers.reservation_url(self, token: self.token, host: 'club-reservation.herokuapp.com')}.")
      return true
    else
      return false
    end
  end


end
