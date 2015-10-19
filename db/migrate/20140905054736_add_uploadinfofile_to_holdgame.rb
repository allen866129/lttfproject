class AddUploadinfofileToHoldgame < ActiveRecord::Migration
  def change
   	add_column :holdgames, :gameinfofile, :string
  end
end
