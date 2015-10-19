class AddZipcodeToTtcourts < ActiveRecord::Migration
  def change
  	add_column :ttcourts, :zipcode, :string
  	add_index :ttcourts, :zipcode
  end
end
