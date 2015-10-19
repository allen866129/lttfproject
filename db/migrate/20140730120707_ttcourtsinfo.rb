class Ttcourtsinfo < ActiveRecord::Migration
  def up
  	create_table :Ttcourtsinfo do |t|
          t.string :placename
          t.float :lat
          t.float :lng
          t.string :city
          t.string :county
          t.text :address
          t.text :text
          t.text :facilities
          t.text :playfee
          t.text :contactinfo
          t.text :supplyinfo
          t.text :infosource
          t.text :infoURL 
          t.timestamps
        end
        
       
    add_index :Ttcourtsinfo, :city
    add_index :Ttcourtsinfo, :county
    add_index :Ttcourtsinfo, :placename
    add_index :Ttcourtsinfo, :lat 
    add_index :Ttcourtsinfo, :lng
  end

  def down
  end
end
