class Groupattendant < ActiveRecord::Base
  attr_accessible :attendee, :gamegroup_id, :phone, :registor_id, :regtype, :teamname
  belongs_to :gamegroup
  has_many :attendants , dependent: :destroy
  default_scope order('id ASC')
  def playerlist 
  	  @playerlist=self.attendants
      @playerlist
  end	

  def findplayer(player_id)
   	  if self.playerlist.find_all{|v| v.player_id==player_id}.empty?
   	    return false
   	  else
   	  	return true
   	  end	
  end	
  

end
