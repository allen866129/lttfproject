class AddCancellationdeadlineToGamegroups < ActiveRecord::Migration
  def change
  	add_column :gamegroups, :cancellation_deadline_flag, :boolean
  	add_column :gamegroups, :cancellation_deadline, :datetime
  end
end
