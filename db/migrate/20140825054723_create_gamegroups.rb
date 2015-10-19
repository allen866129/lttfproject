class CreateGamegroups < ActiveRecord::Migration
  def change
    create_table :gamegroups do |t|
      t.integer :holdgame_id
      t.string :groupname
      t.string :grouptype
      t.integer :noofplayers
      t.integer :noofbackupplayers
      t.string :scorelimitation
      t.integer :scorelow
      t.integer :scorehigh
      t.datetime :starttime
      t.integer :gamefee

      t.timestamps
    end
  end
end
