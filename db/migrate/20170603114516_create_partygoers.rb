class CreatePartygoers < ActiveRecord::Migration[5.0]
  def change
    create_table :partygoers do |t|
      t.references :user, foreign_key: true
      t.references :reservation, foreign_key: true

      t.timestamps
    end
  end
end
