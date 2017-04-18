# encoding: UTF-8;”
class Gamegroup < ActiveRecord::Base
  attr_accessible :gamefee, :groupname, :grouptype, :holdgame_id, :noofbackupplayers, :noofplayers, :scorehigh
  attr_accessible :scorelimitation, :scorelow, :starttime , :regtype
  attr_accessible :double_score_sum_limitation, :double_scorehigh, :double_scorelow
  belongs_to :holdgame
  has_many :groupattendants, dependent: :destroy
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
  def check_single_meet_group_qualify(player_curscore)
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
  def check_double_team_meet_group_qualify(scoresum)
         
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
          if (self.starttime-group.starttime).to_i.abs < (3600*4)
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
