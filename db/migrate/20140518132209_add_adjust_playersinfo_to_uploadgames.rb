class AddAdjustPlayersinfoToUploadgames < ActiveRecord::Migration
  def change
  	add_column :uploadgames, :adjustplayersinfo, :text, :default =>nil
  end
end
