class CreateGroupattendants < ActiveRecord::Migration
  def change
    create_table :groupattendants do |t|
      t.integer :gamegroup_id
      t.string :regtype
      t.string :teamname
      t.string :phone
      t.text :attendee
      t.integer :registor_id

      t.timestamps
    end
  end
end
