#encoding: UTF-8”
class Gsheet4game < ActiveRecord::Base
  attr_accessible :fileulr, :holdgame_id, :in_use
  scope :find_by_holdgameid,->(gameid){where holdgame_id: gameid}
  scope :longtimenouse, -> {where('updated_at > ?', 180.days.ago)}
  scope :available , -> {where( :in_use => false )}

  def self.recycle(holdgame_id)

     @Gsheet=Gsheet4game.find_by_holdgameid(holdgame_id).first
     #@Gsheet=Gsheet4game.find_by_holdgameid(uploadgame.holdgame.id).first
     @Gsheet.in_use=false if @Gsheet
     @Gsheet.save if @Gsheet
  end	

  	
end
