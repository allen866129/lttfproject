class CreateGameholders < ActiveRecord::Migration
  def change
    create_table :gameholders do |t|
      t.integer :user_id
      t.string :name
      t.string :courtname
      t.string :city
      t.string :county
      t.string :zipcode
      t.text :address
      t.float :lng
      t.float :lat
      t.string :phone
      t.string :email
      t.string :sponsor
      t.boolean :approved

      t.timestamps
    end
  end
end
