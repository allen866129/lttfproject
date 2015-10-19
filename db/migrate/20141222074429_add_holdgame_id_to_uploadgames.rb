class AddHoldgameIdToUploadgames < ActiveRecord::Migration
  def change
  	add_column :uploadgames, :holdgame_id, :integer
  end
end
