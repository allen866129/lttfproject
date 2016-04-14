#encoding: UTF-8”
class Holdgame < ActiveRecord::Base
  attr_accessible :enddate, :gameholder_id, :gamename, :gamenote, :gametype, :startdate , :contact_name, :id
  attr_accessible :city, :county, :address, :zipcode, :courtname, :lat, :lng, :url , :lttfgameflag, :contact_phone , :contact_email
  attr_accessible :gameinfofile, :gamedays, :sponsors, :cancel_flag
  belongs_to :gameholder
  has_many :gamecoholders ,dependent: :destroy
  has_many :gamegroups , dependent: :destroy
  has_one :uploadgame
  after_commit :assign_informs_from_holder
  scope :forgamesmaps, order(' zipcode ASC , startdate ASC ')
  default_scope  order('startdate ASC , zipcode ASC ')
  mount_uploader :gameinfofile,  GameInfofileUploader
  before_save :assign_enddate
  accepts_nested_attributes_for :gamecoholders, :allow_destroy => true
  def assign_enddate
     self.gamedays=1 if self.gamedays<=0 || !self.gamedays
     self.enddate=self.startdate+self.gamedays-1 
  end 

  def assign_informs_from_holder

    if self.lttfgameflag
      if !self.courtname
  	    self.city=self.gameholder.city 
  	    self.county=self.gameholder.county 
  	    self.address=self.gameholder.address 
  	    self.courtname=self.gameholder.courtname
  	    self.zipcode=self.gameholder.zipcode
  	    self.lat=self.gameholder.lat
        self.lng=self.gameholder.lng
      end  
      self.contact_name=self.gameholder.name
      self.contact_phone=self.gameholder.phone
      self.contact_email=self.gameholder.email

   	  self.save
    else
      self.zipcode=TWZipCode_hash[self.city][self.county]
      self.save
    end  
  
  end	
  def find_player_ingroups_type(user_id)
    playergroups=Array.new
   
   
    self.gamegroups.each do |gamegroup|
  
    player_gattendant_id= gamegroup.find_player_in_attendants(user_id)
 
      if player_gattendant_id
      
        groups_type=Hash.new
        groups_type['group']=gamegroup
        groups_type['type']=gamegroup.find_official_backup_by_attendant_id(player_gattendant_id)
        playergroups.push(groups_type)
      end
      
    end 
   
    return playergroups 
  end 
  def find_gamecoholder(player_id)
      if self.gamecoholders.find_all{|v| v.co_holderid==player_id}.empty?
        return false
      else
        return true
      end 
  end  

def self.auto_notice
  puts "cron start"
  Rails.logger.info("auto_notice start ")
  puts ("Time Now")
  puts Time.now
  puts ("Time current")
  puts Time.current
  @holdgames=Holdgame.includes(:gameholder).where(:lttfgameflag=>true).where(:cancel_flag=>false).where(:startdate => Time.current.to_date+1)
  @holdgames.each do |holdgame|
        holdgame.gamegroups.each do |group|
          if(group.noofplayers!=0)
            puts (holdgame.startdate.to_s+holdgame.gamename+'==>'+group.groupname)
            @groupattendants=group.groupattendants.in_groups_of(group.noofplayers,false)[0]    
            @groupattendants.each do |groupattend| 
              groupattend.attendants.each  do |player| 
              puts(player.name)
 
                if APP_CONFIG['Mailer_delay']
                  UserMailer.delay.autogamenotice(holdgame, player) 
                else
                  UserMailer.autogamenotice(holdgame, player).deliver 
                end  #if
              end  #player
            end # groupattend
          end  #if 
     
     
        end  #group

  end  #holdgame
end
end
