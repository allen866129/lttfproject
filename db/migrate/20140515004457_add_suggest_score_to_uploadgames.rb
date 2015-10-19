class AddSuggestScoreToUploadgames < ActiveRecord::Migration
  def change
  	add_column :uploadgames, :suggestscore, :integer, :default => nil
  end
end
