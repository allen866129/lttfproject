class ChangeCancellationdeadlineToGamegroups < ActiveRecord::Migration
  def up
  	change_column :gamegroups, :cancellation_deadline_flag, :boolean ,:default => false
  end

  def down
  end
end
