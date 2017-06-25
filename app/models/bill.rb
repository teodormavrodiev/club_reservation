Braintree::Configuration.environment = :sandbox
Braintree::Configuration.merchant_id = ENV["BRAINTREE_MERCHANT_ID"]
Braintree::Configuration.public_key = ENV["BRAINTREE_PUBLIC_KEY"]
Braintree::Configuration.private_key = ENV["BRAINTREE_PRIVATE_KEY"]

class Bill < ApplicationRecord
  belongs_to :user
  belongs_to :reservation

  after_create :accrue_convenience_fee

  enum status: [:unsent, :authorized, :submitted_for_settlement, :accepted, :rejected]

  def authorize
    result = Braintree::Transaction.sale(
      :amount => amount.to_s,
      :payment_method_nonce => one_time_nonce,
      :customer_id => user.braintree_id,
      :options => {
        :store_in_vault_on_success => true,
        :submit_for_settlement => false
      }
    )

    if result.success?
      self.transaction_id = result.transaction.id
      self.status = "authorized"
      self.date_time = DateTime.now
      self.save!
    end
  end

  def submit_for_settlement
    #if status is unsent, submit straight for settlement, by creating new transaction
    #if status is authorized, get the transaction from Braintree using API
    #and the bill's transaction_id and submit the transaction for settlement
    if status == "unsent"
      result = Braintree::Transaction.sale(
        :amount => amount.to_s,
        :payment_method_nonce => one_time_nonce,
        :customer_id => user.braintree_id,
        :options => {
          :store_in_vault_on_success => true,
          :submit_for_settlement => true
        }
      )
      if result.success?
        self.transaction_id = result.transaction.id
        self.status = "submitted_for_settlement"
        self.date_time = DateTime.now
        self.save!
      end
    elsif status == "authorized"
      result = Braintree::Transaction.submit_for_settlement(self.transaction_id)
      if result.success?
        self.status = "submitted_for_settlement"
        self.save!
      end
    end
  end

  def check_whether_settled_and_update
    transaction = Braintree::Transaction.find(self.transaction_id)
    if transaction.status == "settled"
      self.status = "accepted"
      self.save!
    elsif transaction.status == "failed"
      self.status = "rejected"
      self.save!
    end
  end

  def void
    check_whether_settled_and_update
    if self.status == "accepted"
      result = Braintree::Transaction.refund(self.transaction_id)
      unless result.success?
        BillMailer.bill_failed_to_refund(self.id).deliver_later
      end
    else
      result = Braintree::Transaction.void(self.transaction_id)
      unless result.success?
        BillMailer.bill_failed_to_void(self.id).deliver_later
      end
    end
  end

  def send_email_confirmation_after_submitted
    BillMailer.bill_submitted_successfully(self.id).deliver_later
  end

  def send_email_for_failure_of_settlement(time_to_respond)
    BillMailer.failure_to_settle(self.id, time_to_respond).deliver_later
  end

  def send_email_for_failure_of_authorization(time_to_respond)
    BillMailer.failure_to_authorize(self.id, time_to_respond).deliver_later
  end

  def accrue_convenience_fee
    self.amount = self.amount*1.05
    self.save!
  end

end
