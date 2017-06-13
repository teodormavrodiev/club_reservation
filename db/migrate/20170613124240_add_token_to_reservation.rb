class AddTokenToReservation < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :token, :string
    add_index :reservations, :token, unique: true
  end
end
