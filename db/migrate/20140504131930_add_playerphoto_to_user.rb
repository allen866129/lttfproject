class AddPlayerphotoToUser < ActiveRecord::Migration
  def change
  	add_column :users, :playerphoto, :string
  end
end
