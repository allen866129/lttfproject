class Courtphoto < ActiveRecord::Base
  attr_accessible :photo, :ttcourt_id
  mount_uploader :photo, CourtphotoUploader
  belongs_to :ttcourt
end
