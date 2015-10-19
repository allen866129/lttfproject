class Attendant < ActiveRecord::Base
  attr_accessible :curscore, :email, :groupattendant_id, :name, :phone, :registor_id, :regtype, :string, :teamname
  attr_accessible :player_id
  default_scope order('created_at ASC')
  belongs_to :groupattendant
end
