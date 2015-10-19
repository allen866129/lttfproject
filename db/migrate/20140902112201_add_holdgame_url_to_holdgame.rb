class AddHoldgameUrlToHoldgame < ActiveRecord::Migration
  def change
  	add_column :holdgames, :url, :string
  end
end
