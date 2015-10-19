class AddPlayerIdToAttendants < ActiveRecord::Migration
  def change
  	 add_column :attendants, :player_id, :integer
  end
end
