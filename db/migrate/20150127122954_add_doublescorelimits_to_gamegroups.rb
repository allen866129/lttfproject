class AddDoublescorelimitsToGamegroups < ActiveRecord::Migration
  def change
  	add_column :gamegroups, :double_score_sum_limitation, :text
  	add_column :gamegroups, :double_scorehigh, :integer
    add_column :gamegroups, :double_scorelow, :integer
  end
end
