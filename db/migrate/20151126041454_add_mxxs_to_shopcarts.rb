class AddMxxsToShopcarts < ActiveRecord::Migration
  def change
  	add_column :shopcarts, :M, :integer ,:default => 0, :null => false
  	add_column :shopcarts, :XXS, :integer  ,:default => 0, :null => false	
  end
end
