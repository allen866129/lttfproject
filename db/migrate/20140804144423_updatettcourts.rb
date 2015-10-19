class Updatettcourts < ActiveRecord::Migration
  def up
  	  	drop_table :ttcourts
        create_table :ttcourts do |t|
           t.string :placename
          t.float :lng
          t.float :lat
          t.string :city
          t.string :county
          t.string :zipcode
          t.text :address
          t.text :opentime
          t.text :facilities
          t.text :playfee
          t.text :contactinfo
          t.text :supplyinfo
          t.text :infosource
          t.text :infoURL 
          t.timestamps
        end
        
       
    add_index :ttcourts, :city
    add_index :ttcourts, :county
    add_index :ttcourts, :placename
    add_index :ttcourts, :lng
    add_index :ttcourts, :lat 
    add_index :ttcourts, :zipcode

    
 
  end

  def down
  end
end
