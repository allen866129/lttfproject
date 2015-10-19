class CreateGames < ActiveRecord::Migration
  def change
    
    create_table :games do |t|
      t.string :gamename
      t.date :gamedate
      t.text :players_result
      t.string :uploader
      t.text :detailgameinfo
      t.string :originalfileurl

      t.timestamps
    end
  end
end
