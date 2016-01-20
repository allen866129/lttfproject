class AddDefaultvalueToShopcarts < ActiveRecord::Migration
  def change
    change_column :shopcarts, :X5L, :integer, :default => 0, :null => false
    change_column :shopcarts, :X4L, :integer, :default => 0, :null => false
    change_column :shopcarts, :X3L, :integer, :default => 0, :null => false
    change_column :shopcarts, :X2L, :integer, :default => 0, :null => false
    change_column :shopcarts, :L, :integer, :default => 0, :null => false
    change_column :shopcarts, :S, :integer, :default => 0, :null => false
    change_column :shopcarts, :XS, :integer, :default => 0, :null => false  
  end
end
