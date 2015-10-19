class ChangeTextToOpentimeOnTtcourts < ActiveRecord::Migration
  def up
  	rename_column :ttcourts , :text , :opentime
  end

  def down
  end
end
