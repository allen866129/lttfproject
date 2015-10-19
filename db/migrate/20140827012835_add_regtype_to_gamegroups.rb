class AddRegtypeToGamegroups < ActiveRecord::Migration
  def change
  	add_column :gamegroups, :regtype, :string
  end
end
