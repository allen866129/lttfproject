class Gamecoholder < ActiveRecord::Base
   attr_accessible :holdgame_id, :co_holderid
   belongs_to :holdgame
   def name
   	 User.find(self.co_holderid).username
   end
   	
end
