class CreateUploadgame < ActiveRecord::Migration
  def change
  
    create_table :Uploadgame do |t|
      t.string :gamename
      t.date :gamedate
      t.text :players_result
      t.string :uploader
      t.text :detailgameinfo
      t.string :originalfileurl
      t.boolean :publichforchecking
      t.timestamps
    end
  end
end
