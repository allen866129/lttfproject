class AddInputfileurlToHoldgame < ActiveRecord::Migration
  def change
  	add_column :holdgames, :inputfileurl, :string
  end
end
