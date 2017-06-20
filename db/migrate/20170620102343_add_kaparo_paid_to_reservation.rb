class AddKaparoPaidToReservation < ActiveRecord::Migration[5.0]
  def change
    add_column :reservations, :kaparo_paid, :boolean
  end
end
