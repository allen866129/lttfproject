class Advitem < ActiveRecord::Base
  attr_accessible :adv_link, :adv_photo, :creator_id, :end_date, :provider_name, :provider_tel
  mount_uploader :adv_photo, AdvPhotoUploader 
def creator
  User.find(self.creator_id) 
end
def self.reloadadvs
   @side_advitems = self.all	
end  
end
