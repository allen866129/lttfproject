class AddCancelflagToHoldgames < ActiveRecord::Migration
  def change
  	 add_column :holdgames, :cancel_flag, :boolean, :default => false
  end
end
