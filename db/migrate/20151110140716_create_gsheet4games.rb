class CreateGsheet4games < ActiveRecord::Migration
  def change
    create_table :gsheet4games do |t|
      t.string :fileulr
      t.integer :holdgame_id
      t.boolean :in_use , :null => false, :default => false

      t.timestamps
    end
  end
end
