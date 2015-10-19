class AddScorecaculatedToUploadgames < ActiveRecord::Migration
  def change
  	add_column :uploadgames, :scorecaculated, :boolean 
  end
end
