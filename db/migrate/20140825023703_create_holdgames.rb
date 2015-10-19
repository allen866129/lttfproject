class CreateHoldgames < ActiveRecord::Migration
  def change
    create_table :holdgames do |t|
      t.integer :gameholder_id
      t.string :gamename
      t.date :startdate
      t.date :enddate
      t.string :gametype
      t.text :gamenote

      t.timestamps
    end
  end
end
