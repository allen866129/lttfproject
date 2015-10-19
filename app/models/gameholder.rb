class Gameholder < ActiveRecord::Base
  attr_accessible :address, :approved, :city, :county, :courtname, :email, :lat, :lng, :name, :phone, :sponsor, :user_id, :zipcode

  scope :waitingforapprove, where( :approved => false )
  scope :alreadyapproved, where( :approved => true )
  belongs_to :user
  has_many :holdgames, dependent: :destroy
  has_many :blacklists, dependent: :destroy
  default_scope order('user_id ASC')
  after_commit :assign_zipcode
  def assign_zipcode
  	self.zipcode=TWZipCode_hash[self.city][self.county]
  	self.save
  end	
end
