class AddRegFlagToGamegroup < ActiveRecord::Migration
  def change
  	add_column :gamegroups, :registration_deadline, :datetime
  	add_column :gamegroups, :registration_deadline_flag, :boolean, default:false
  end
end
