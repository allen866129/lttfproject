class AddTakeormailToShopcarts < ActiveRecord::Migration
  def change
  	 add_column :shopcarts, :take_or_mail, :string
  end
end
