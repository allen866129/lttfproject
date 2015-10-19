#encoding: UTF-8”
class Authorization < ActiveRecord::Base
  # attr_accessible :title, :body
  	belongs_to :user

	after_create :fetch_details



	def fetch_details
		self.send("fetch_details_from_#{self.provider.downcase}")
	end


	def fetch_details_from_facebook
		
		graph = Koala::Facebook::API.new(self.token)
		facebook_data = graph.get_object("me?locale='zh_TW'")
		 #self.user.fbaccount = facebook_data['username']
		#self.save
		#self.user.save

	end

end
