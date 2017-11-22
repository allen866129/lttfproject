class Webpageview < ActiveRecord::Base
  attr_accessible :ttcourts_views
  def ttcourts_views_increment(by = 1)
    self.ttcourts_views ||= 0
    self.ttcourts_views += by
    self.save
  end
end
