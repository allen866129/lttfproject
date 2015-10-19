class CreateNewCourtphoto < ActiveRecord::Migration
  def up
  	    create_table :courtphotos do |t|
      t.integer :ttcourt_id
      t.string :photo

      t.timestamps
      end
  end

  def down
  end
end
