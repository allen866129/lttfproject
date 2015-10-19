class AddRecorderToUploadgames < ActiveRecord::Migration
  def change
  	add_column :uploadgames, :recorder, :string 
  end
end
