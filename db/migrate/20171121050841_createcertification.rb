class Createcertification < ActiveRecord::Migration
  def up
  	create_table :certifications do |t|
      t.belongs_to :authcertunit, index: true
      t.belongs_to :user, index: true
    
      t.timestamps
    end
  end

  def down
  end
end
