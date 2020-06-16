# encoding: UTF-8;”
class Gamegroup < ActiveRecord::Base
  attr_accessible :gamefee, :groupname, :grouptype, :holdgame_id, :noofbackupplayers, :noofplayers, :scorehigh
  attr_accessible :scorelimitation, :scorelow, :starttime , :regtype
  attr_accessible :double_score_sum_limitation, :double_scorehigh, :double_scorelow
  attr_accessible :cancellation_deadline_flag, :cancellation_deadline
  attr_accessible :registration_deadline_flag, :registration_deadline
  attr_accessible :minimal_LTTF_games_limited, :authcerts ,:need_authcert_flag, :authcondition
  belongs_to :holdgame
  has_many :groupattendants, dependent: :destroy
 # before_save :check_cancel_date_time
  default_scope {order('id ASC')}
  def self.regtypes
   {'single'=>'個人', 'double'=>'雙人', 'team'=>'團體'}
  end
  def find_player_in_attendants(player_id)
  	self.groupattendants.each do |attendee|
  	  if attendee.findplayer(player_id)
  	    return attendee.id 
  	  end 	
  	end	
  	return nil
  end
  def check_cancel_date_time

    self.cancellation_deadline_flag= false if !cancellation_deadline 
    #self.save
  end
  def  rating_stars_picture

      case  self.minimal_LTTF_games_limited

        when '無限制(0顆星)'

          file_path="zero_star.png"  
          
        when '5場以上(一顆星)'
          file_path="one_star.png"  
          
        when '10場以上(二顆星)'
           file_path="two_stars.png"  
          
        when '20場以上(三顆星)'
          file_path="three_stars.png"  
          
        when '50場以上(四顆星)'
           file_path="four_stars.png"  
          
        when '100場以上(五顆星)'
           file_path="five_stars.png"  
             
        else
          file_path="zero_star.png"  
         end
       return file_path 
  end 
  def authcertunit
      authcertunit=Authcertunit.where(:unitname => self.authcerts).first
      return authcertunit
  end
  def authcert_logo
    
    logopath=self.authcertunit.unitlogo_url(:tiny)

    return logopath
  end
  def single_limit_string
     case self.scorelimitation
      when '無積分限制'
         return '個人: 無限制'
      when '限制高低分'
       return ('個人: '+self.scorelow.to_s+'~~'+self.scorehigh.to_s)
      when '限制最高分'
         return ('個人: 小於'+self.scorehigh.to_s) 
      when '限制最低分'                                    
        return ('個人: 大於'+self.scorelow.to_s) 
    end 
  end
  def double_team_limit_string
     case self.double_score_sum_limitation
      when '無積分限制'
         return '積分總和: 無限制'
      when '限制高低分'
       return ('積分總和: '+self.double_scorelow.to_s+'~~'+self.double_scorehigh.to_s)
      when '限制最高分'
         return ('積分總和: 小於'+self.double_scorehigh.to_s) 
      when '限制最低分'                                    
        return ('積分總和: 大於'+self.double_scorelow.to_s) 
    end 
    
  end
  def check_player_meet_group_cert(player)

    pass_minigame_flag=false
    case  self.minimal_LTTF_games_limited

        when '5場以上(一顆星)'
         pass_minigame_flag=true if player.playerprofile.get_star_numbers>0
          
        when '10場以上(二顆星)'
          pass_minigame_flag=true if player.playerprofile.get_star_numbers>1
          
        when '20場以上(三顆星)'
         pass_minigame_flag=true if player.playerprofile.get_star_numbers>2
          
        when '50場以上(四顆星)'
          pass_minigame_flag=true if player.playerprofile.get_star_numbers>3
          
        when '100場以上(五顆星)'
          pass_minigame_flag=true if player.playerprofile.get_star_numbers>4
             
        else
          pass_minigame_flag=true
         end
    if self.authcertunit
        
      if self.authcertunit.users.include?(player)
        pass_authcert_flag=true
      else
        pass_authcert_flag=false
       end
    else
      pass_authcert_flag=true
    end 

    if self.need_authcert_flag
        if self.authcondition=='參賽次數&認證單位核可兩項皆須符合'

            return pass_authcert_flag && pass_minigame_flag
        else
            return pass_authcert_flag || pass_minigame_flag
        end   
    end  
    return pass_minigame_flag
  end
  def check_single_meet_group_score_qualify(player_curscore)
    return true if player_curscore==0
      
  	case self.scorelimitation
      when '無積分限制'
         return true
      when '限制高低分'
       return( (player_curscore >= self.scorelow) &&
            (player_curscore<=self.scorehigh) )
      when '限制最高分'
         return (player_curscore<=self.scorehigh) 
      when '限制最低分'                                    
        return (player_curscore>=self.scorelow) 
    end	
  end
  def check_double_team_meet_group_score_qualify(scoresum)
         
    case self.double_score_sum_limitation
      when '無積分限制'
         return true
      when '限制高低分'
       return( (scoresum >= self.double_scorelow) &&
            (scoresum<=self.double_scorehigh) )
      when '限制最高分'
         return (scoresum<=self.double_scorehigh) 
      when '限制最低分'                                    
        return (scoresum>=self.double_scorelow) 
    end 
  end

  def check_regsitered_same_timeframe_group(user)

   
    user.find_reg_unplay_groups.each do |group|

        if group.holdgame != self.holdgame 
          temp=(self.starttime-group.starttime).to_i.abs 
          if (self.starttime-group.starttime).to_i.abs < (3600*3)
            return true
          end 
        end 
    end  
    
    false
  end
  def allplayers
    playerlist=Array.new
    self.groupattendants.each do |attendrecord|
      playerlist=playerlist+attendrecord.playerlist 
    end  
  end  
  def allgroupattendee
    case self.regtype
      when 'single'
        playerlist=Array.new
        self.groupattendants.each do |attendrecord|
          playerlist=playerlist+attendrecord.attendants
        end  
        return playerlist
      when 'double' 
        playerlist=Array.new
        self.groupattendants.each do |attendrecord|
          playerlist=playerlist+attendrecord.attendants.in_groups_of(2) 
        end 
        return playerlist
      when 'team' 
        playerlist=Array.new
        self.groupattendants.each do |attendrecord|
        playerlist=playerlist+attendrecord.attendants.in_groups_of(20,false) 
        end 
        return playerlist 
    end
  end

  def findplayer(player_id)

    self.groupattendants.each do |attendrecord|
     return true if attendrecord.findplayer(player_id)  
    end 
    false 
  end
  def check_official_backup(gattend_id)
    
     match_index = self.groupattendants.index(self.groupattendants.find { |l| l.id == gattend_id })
     if match_index <self.noofplayers
       return '正選'
     else
       return '候補'
     end  
  end
  def find_official_backup_by_attendant_id(gattend_id)
      
      return self.check_official_backup(gattend_id)

  end
  def totalresgisteredsplayersno
   
    return self.groupattendants.length
     
  end
end
