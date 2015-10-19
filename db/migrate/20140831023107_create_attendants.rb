class CreateAttendants < ActiveRecord::Migration
  def change
    create_table :attendants do |t|
      t.integer :groupattendant_id
      t.string :name
      t.string :phone
      t.integer :curscore
      t.string :email
      t.string :regtype
      t.string :string
      t.integer :registor_id
      t.string :teamname

      t.timestamps
    end
  end
end
