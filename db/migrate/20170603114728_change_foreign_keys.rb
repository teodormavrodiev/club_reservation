class ChangeForeignKeys < ActiveRecord::Migration[5.0]
  def change
    rename_column :clubs, :user_id, :club_owner_id
    rename_column :reservations, :user_id, :reservation_owner_id
    rename_column :partygoers, :user_id, :partygoer_id
  end
end
