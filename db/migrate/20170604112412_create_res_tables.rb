class CreateResTables < ActiveRecord::Migration[5.0]
  def change
    create_table :res_tables do |t|
      t.references :reservation, foreign_key: true
      t.references :table, foreign_key: true

      t.timestamps
    end
  end
end
