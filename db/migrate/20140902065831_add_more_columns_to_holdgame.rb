class AddMoreColumnsToHoldgame < ActiveRecord::Migration
  def change
  	 add_column :holdgames, :address, :text
  	 add_column :holdgames, :city, :string
  	 add_column :holdgames, :county, :string
  	 add_column :holdgames, :zipcode, :string
  	 add_column :holdgames, :courtname, :string
  	 add_column :holdgames, :lat, :float
  	 add_column :holdgames, :lng, :float
  end
end
