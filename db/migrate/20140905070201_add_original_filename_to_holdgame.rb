class AddOriginalFilenameToHoldgame < ActiveRecord::Migration
  def change
  	   	add_column :holdgames, :original_filename, :string
  end
end
