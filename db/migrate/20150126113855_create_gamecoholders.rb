class CreateGamecoholders < ActiveRecord::Migration
  def change
    create_table :gamecoholders do |t|
      t.integer :holdgame_id
      t.integer :co_holderid
      t.timestamps
    end
  end
end
