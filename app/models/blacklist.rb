class Blacklist < ActiveRecord::Base
  attr_accessible :gameholder_id, :note, :player_name, :playerprofile_id
  belongs_to :gameholder
end
