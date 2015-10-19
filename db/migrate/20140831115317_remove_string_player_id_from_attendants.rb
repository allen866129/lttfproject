class RemoveStringPlayerIdFromAttendants < ActiveRecord::Migration
  def up
  	remove_column :attendants , :string

  end

  def down
  end
end
