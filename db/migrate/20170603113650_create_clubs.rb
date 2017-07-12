class CreateClubs < ActiveRecord::Migration[5.0]
  def change
    create_table :clubs do |t|
      t.string :name
      t.integer :capacity
      t.text :description
      t.string :location
      t.string :region
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
