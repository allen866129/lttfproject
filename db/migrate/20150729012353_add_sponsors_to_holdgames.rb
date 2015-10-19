class AddSponsorsToHoldgames < ActiveRecord::Migration
  def change
    add_column :holdgames, :sponsors, :text
  end
end
