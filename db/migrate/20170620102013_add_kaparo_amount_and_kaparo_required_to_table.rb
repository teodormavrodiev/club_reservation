class AddKaparoAmountAndKaparoRequiredToTable < ActiveRecord::Migration[5.0]
  def change
    add_column :tables, :kaparo_required, :boolean
    add_column :tables, :kaparo_amount, :integer
  end
end
