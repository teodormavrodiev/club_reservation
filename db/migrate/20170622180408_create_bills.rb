class CreateBills < ActiveRecord::Migration[5.0]
  def change
    create_table :bills do |t|
      t.references :user, foreign_key: true
      t.references :reservation, foreign_key: true
      t.datetime :date_time
      t.integer :status
      t.string :transaction_id
      t.float :amount

      t.timestamps
    end
  end
end
