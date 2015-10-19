class CreateBlacklists < ActiveRecord::Migration
  def change
    create_table :blacklists do |t|
      t.integer :gameholder_id
      t.integer :playerprofile_id
      t.text :player_name
      t.text :note

      t.timestamps
    end
  end
end
