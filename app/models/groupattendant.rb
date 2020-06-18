class Groupattendant < ActiveRecord::Base
  attr_accessible :attendee, :gamegroup_id, :phone, :registor_id, :regtype, :teamname
  belongs_to :gamegroup
  has_many :attendants , :dependent => :destroy

  default_scope {order('id ASC')}
  def playerlist 
  	  @playerlist=self.attendants
      @playerlist
  end	
  def players_to_users
    users= Array.new
    self.attendants.each do |attendant|
      user=User.find(attendant.player_id)
      users.push(user)
    end  
    return users
  end  
  def findplayer(player_id)
   	  if self.playerlist.find_all{|v| v.player_id==player_id}.empty?
   	    return false
   	  else
   	  	return true
   	  end	
  end	


end
