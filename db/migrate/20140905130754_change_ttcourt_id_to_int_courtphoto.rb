class ChangeTtcourtIdToIntCourtphoto < ActiveRecord::Migration
  def up
  	drop_table :courtphotos
  end

  def down
  end
end
