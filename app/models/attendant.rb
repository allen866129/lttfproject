class Attendant < ActiveRecord::Base
  attr_accessible :curscore, :email, :groupattendant_id, :name, :phone, :registor_id, :regtype, :string, :teamname
  attr_accessible :player_id
  default_scope {order('created_at ASC')}
  belongs_to :groupattendant

def stars_picture

	user=User.find(self.player_id)
	#@user.rating_stars_picture
	return user.rating_stars_picture
end	
def attand_phone_from_user
	user=User.find(self.player_id)
	return user.phone
end
def attand_email_from_user
	user=User.find(self.player_id)
	return user.email
end
def score_in_time
	user=User.find(self.player_id)
	return user.playerprofile.current_score
	
end
end
