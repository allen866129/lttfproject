class CreatePlayerprofiles < ActiveRecord::Migration
  def change
    create_table :playerprofiles do |t|
      t.integer   :user_id
      t.string   :name
      t.integer  :initscore     ,       :default=>0
  	  t.integer  :curscore         
  	  t.integer  :totalwongames   ,    :default=>0
  	  t.integer  :totallosegames ,     :default=>0
  	  t.date     :lastgamedate        
  	  t.string   :lastgamename      
  	  t.date     :lastscoreupdatedate
      t.text     :gamehistory      
  	  t.string   :profileurl   
  	  t.string   :imageurl          
  	  t.string   :bio              
  	  t.string   :paddleholdtype 
  	  t.string   :paddlemodel 
      t.string   :forwardrubber 
      t.string   :backrubber
    
      t.timestamps
    end
  end
end
