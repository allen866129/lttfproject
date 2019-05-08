class Authcertunit < ActiveRecord::Base
  attr_accessible :address, :majorcontact_id, :tel, :unitlogo, :unitname
  has_many :certifications
  has_many :users, through: :certifications
   mount_uploader :unitlogo, AuthCertUnitImageUploader


  def contact_user
  	  user=User.find(self.majorcontact_id)
  	  return user
  end  
  
end
