class Gameholder < ActiveRecord::Base
  attr_accessible :address, :approved, :city, :county, :courtname, :email, :lat, :lng, :name, :phone, :sponsor, :user_id, :zipcode

  scope :waitingforapprove,->{ where( :approved => false )}
  scope :alreadyapproved, -> {where( :approved => true )}
  belongs_to :user
  has_many :holdgames, dependent: :destroy
  has_many :blacklists, dependent: :destroy
  default_scope {order('user_id ASC')}
  before_save :assign_zipcode
  def assign_zipcode
  	self.zipcode=TWZipCode_hash[self.city][self.county]
  end	
  def prize_games_count
    return self.holdgames.where(:startdate =>APP_CONFIG['award_statistic_start_date']..APP_CONFIG['award_statistic_end_date']).count
 
  end
end
