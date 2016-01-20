class AddXlToShopcarts < ActiveRecord::Migration
  def change
  	add_column :shopcarts, :XL, :integer
  end
end
