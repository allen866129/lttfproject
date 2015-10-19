class CreateTtcourts < ActiveRecord::Migration
  def change
  	drop_table :Ttcourtsinfo
    create_table :ttcourts do |t|
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
        
       
    add_index :ttcourts, :city
    add_index :ttcourts, :county
    add_index :ttcourts, :placename
    add_index :ttcourts, :lat 
    add_index :ttcourts, :lng

    
  end
end
