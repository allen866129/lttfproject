class CreateUploadgames < ActiveRecord::Migration
  def change
    create_table :uploadgames do |t|
      t.string :gamename
      t.date :gamedate
      t.text :players_result
      t.string :uploader
      t.text :detailgameinfo
      t.string :originalfileurl
      t.boolean :publishedforchecking

      t.timestamps
    end
  end
end
