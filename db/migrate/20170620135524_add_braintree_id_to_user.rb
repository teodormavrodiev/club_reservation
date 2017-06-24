class AddBraintreeIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :braintree_id, :string
    add_index :users, :braintree_id, unique: true
  end
end
