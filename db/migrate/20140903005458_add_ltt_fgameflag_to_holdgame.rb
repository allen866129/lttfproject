class AddLttFgameflagToHoldgame < ActiveRecord::Migration
  def change
  	add_column :holdgames, :lttfgameflag, :boolean ,  :default=> false
  end
end
