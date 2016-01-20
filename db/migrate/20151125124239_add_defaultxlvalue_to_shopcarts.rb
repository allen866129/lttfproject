class AddDefaultxlvalueToShopcarts < ActiveRecord::Migration
  def change
  	    change_column :shopcarts, :XL, :integer, :default => 0, :null => false
  end
end
