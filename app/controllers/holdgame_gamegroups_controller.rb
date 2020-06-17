# encoding: UTF-8;”
class HoldgameGamegroupsController < ApplicationController
 before_filter :authenticate_user!, :except=>[:index,:teamplayersinput, :singleplayerinput, :doubleplayersinput, :cancel_player_registration, :update, :find_holdgame]
 layout :resolve_layout 
 before_filter :find_holdgame 



  def publishtoFB
    #if  current_user.authorizations.pluck(:provider).include?('facebook') 
      #UserMailer.newholdgame_publish_notice_to_FB( @holdgame,  session[:access_token]).deliver  if  session[:access_token] 
      #b.newholdgame_publish_notice_to_FB( @holdgame,  current_user.authorizations.where(:provider => 'facebook').last.token ).deliver   
      UserMailer.newholdgame_publish_notice_to_FB( @holdgame ).deliver     
      flash[:success]="已將本賽事公告於桌盟FB!"
    #else
    #   flash[:error]="請將您的桌盟帳號與FB帳號連結,才能執行此功能!"
    #end  
     redirect_to :action => "index"
  end 
  def check_in_blacklist (user_id)
    return @gameholder.blacklists.find{|b| b.playerprofile_id==user_id}
  end
def index

  if current_user
    gon.log_in = 1
    if !current_user.phone
       gon.nophone = 1
    end  
  else
    gon.log_in = 0
  end
   if current_user
     @in_blacklist_data = check_in_blacklist(current_user.id)
   else
     @in_blacklist_data =nil
   end 

  gon.blacklist=1 if @in_blacklist_data
  gon.doubleresistered=0
  @doubleresistered= false
  @gamegroups = @holdgame.gamegroups
  if current_user
    @gamegroups.each do |gamegroup|
    
      if gamegroup.check_regsitered_same_timeframe_group(current_user)
        gon.doubleresistered=1
        @doubleresistered= true
      end  
    end
  end 
  if !params[:targroupid] && !@gamegroups.empty?
    @targetgroup_id=@gamegroups.first.id
   
    #@gamegroup=@holdgame.gamegroups.first
  else
    @targetgroup_id=params[:targroupid].to_i
  end 

  @player_current_score=Hash.new
  @groupaddtndant_registor_name=Hash.new
  @gamegroups.each do |gamegroup|
    gamegroup.allgroupattendee.flatten.each do |player|
      if player
         @player_current_score[player.player_id]=User.find(player.player_id).playerprofile.curscore 
      end   
    end
    if gamegroup.regtype=='team'
      gamegroup.groupattendants.each do |attendant|
        @groupaddtndant_registor_name[attendant.id]=User.find(attendant.registor_id).username
      end  
    end
  end
 
end
def create_attendee_array(gamegroups)
  @attendee_array=Hash.new
  @user_in_groups=Hash.new
  @user_current_score=Hash.new
  gamegroups.each do |gamegroup|
    @group_attendee_array=Array.new

    if(!gamegroup.groupattendants.empty? )
       
        gamegroup.groupattendants.each do |attendant|
          @temp=attendant.playerlist
          @group_attendee_array.push(@temp)
     
          user_in_group=@temp.find_all{|v|v['user_id']==current_user.id}
          if(!user_in_group.empty?)
            @user_in_groups[gamegroup.id]=attendant.id
          else
            @user_in_groups[gamegroup.id]=nil
          end  
         
      end  
    end

    
    @attendee_array[gamegroup.id]=@group_attendee_array
  end

  @attendee_array
end

def check_user_meetgroupqualify(gamegroups, player_id)
  user_meet_groups=Hash.new
  player=User.find(player_id)

  gamegroups.each do |gamegroup|
 
    user_meet_groups[gamegroup.id]=gamegroup.check_meet_group_score_qualify(player.playerprofile.current_score)&&gamegroup.check_player_meet_group_cert(player)
  end  
  return user_meet_groups
end

def preparesendmail
   @message= params[:message]
   @subject= params[:subject]
   @gamegroups = @holdgame.gamegroups
   gon.gamegroups=@gamegroups 
   @player_email=Hash.new
   @backupplayerlist=Array.new
   @gamegroups.each do |gamegroup|
     gamegroup.allgroupattendee.flatten.each do |player|
       @player_email[player.player_id]=false
     end 

      if(gamegroup.noofplayers!=0)
        groupbackup=gamegroup.allgroupattendee.in_groups_of(gamegroup.noofplayers,false)[1]
        
        @backupplayerlist=@backupplayerlist+groupbackup.flatten if groupbackup
      
       else

        @backupplayerlist=gamegroup.allgroupattendee.flatten
      end  
   end
   gon.player_email=@player_email
   @backupplayerIDlist=Array.new
   @backupplayerlist.flatten.each do |player|
     @backupplayerIDlist.push(player.player_id.to_s) 

   end 

   gon.backupplayerlist=@backupplayerlist
   gon.backupplayerIDlist = @backupplayerIDlist
   #@groupttendee= @gamegroup.groupattendants
   #@attendee =@gamegroup.allgroupattendee
end 
def sendemail

  subject=params[:subject]
  message=params[:message]
  playersemail=params[:playersemail]
  @gamegroups = @holdgame.gamegroups
  @gamegroups.each do |gamegroup|
    gamegroup.allgroupattendee.flatten.each do |player|

      if player
        if  playersemail[player.player_id.to_s]=="1"
          #UserMailer.sendgamenotice(@holdgame, player, subject,message).deliver 
          if APP_CONFIG['Mailer_delay']
            UserMailer.delay.sendgamenotice(@holdgame, player, subject,message)
          else
            UserMailer.sendgamenotice(@holdgame, player, subject,message).deliver 
          end      
        end 
      end 
     end 
    end
  if APP_CONFIG['Mailer_delay']
    UserMailer.delay.game_holders_gamenotice_backup(@holdgame, subject,message)
  else
    UserMailer.delay.game_holders_gamenotice_backup(@holdgame, subject,message).deliver 
  end  

  flash[:success]="郵寄寄發作業已完成!"
  
  redirect_to  preparesendmail_holdgame_gamegroups_path(@holdgame, :subject=>subject , :message=>message)
end 

def registration

     @curgroup=Gamegroup.find(params[:format])
     if !@curgroup.allgroupattendee.find{|a| a.name==current_user.username}

     attendantrecord=@curgroup.groupattendants.build
    
     Groupattendant.transaction do
     
     attendantrecord.regtype= @curgroup.regtype
     #attendantrecord.attendee='(,'+current_user.id.to_s+','+current_user.username+','+current_user.email+','+''+')'
     attendantrecord.phone=current_user.phone
     attendantrecord.registor_id=current_user.id
     if attendantrecord.save
       player=attendantrecord.attendants.build
       player.regtype=attendantrecord.regtype
       player.phone=attendantrecord.phone
        player.registor_id=attendantrecord.registor_id
        player.player_id=current_user.id
        player.name=current_user.username
        player.email=current_user.email
        player.curscore=current_user.playerprofile.curscore
        player.save
        send_register_notice_single(@curgroup,player,'register',@curgroup.holdgame.find_allgameholders)
     end 
   end 
  end
    #@gamegroups = @holdgame.gamegroups
    #@attendee=create_attendee_array(@gamegroups)
    #@targettabindex=@gamegroups.index(@curgroup)+1
   
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@curgroup.id})
end  
def singleregistration(group_id, playerids)
  
  @curgroup=Gamegroup.find(group_id)

  @playerlist=Array.new
  @playerlist=User.find(playerids) if playerids

  Groupattendant.transaction do
    @playerlist.each do |player|  
      attendantrecord=@curgroup.groupattendants.build 
      attendantrecord.regtype= @curgroup.regtype
      attendantrecord.phone=player.phone
      attendantrecord.registor_id=current_user.id
      if attendantrecord.save
        attendant=attendantrecord.attendants.build
        attendant.regtype=attendantrecord.regtype
        attendant.phone=attendantrecord.phone
        attendant.registor_id=attendantrecord.registor_id
        attendant.player_id=player.id
        attendant.name=player.username
        attendant.email=player.email
        attendant.curscore=player.playerprofile.curscore
        attendant.save
       
        send_register_notice_single(@curgroup,attendant,'register',@curgroup.holdgame.find_allgameholders)
      end
   
    end 
  end

end 

def doubleregistration(group_id, playerids)
  
  @curgroup=Gamegroup.find(group_id)

  #@playerlist=Array.new
  @playerlist=User.where(:id=> playerids).order_by_ids(playerids).in_groups_of(2)
  Groupattendant.transaction do
    #attendantrecord.phone=current_user.phone
    #attendantrecord.registor_id=current_user.id
    
      @playerlist.each do |players|
        @attendantrecord=@curgroup.groupattendants.build 
        @attendantrecord.registor_id=current_user.id
        @attendantrecord.regtype= @curgroup.regtype
        for player in players
          attendant=@attendantrecord.attendants.build
          attendant.regtype=@attendantrecord.regtype
          attendant.phone=player.phone
          attendant.registor_id=@attendantrecord.registor_id
          attendant.player_id=player.id
          attendant.name=player.username
          attendant.email=player.email
          attendant.curscore=player.playerprofile.curscore
          attendant.save
        end
        @attendantrecord.save
        send_register_notice_double(@curgroup,@attendantrecord, @playerlist,'register',@curgroup.holdgame.find_allgameholders)
      end 
   
   
  end 
end  
def teamregistration(group_id, playerlist,teamname,old_attendantrecord)
  
  @curgroup=Gamegroup.find(group_id)
  if !old_attendantrecord
     @type='register'
     @attendantrecord=@curgroup.groupattendants.build 
  else
    @type='playerschanged'
    @attendantrecord=Groupattendant.find(old_attendantrecord) 
    @attendantrecord.attendants.delete_all
  end  
  
  @playerlist=playerlist.in_groups_of(20,false) 
  Groupattendant.transaction do
     
    @attendantrecord.regtype= @curgroup.regtype
    @attendantrecord.phone=current_user.phone
    @attendantrecord.registor_id=current_user.id
    @attendantrecord.teamname=teamname
    if @attendantrecord.save
      @playerlist.each do |players|
        for player in players
          attendant=@attendantrecord.attendants.build
          attendant.regtype=@attendantrecord.regtype
          attendant.phone=player.phone
          attendant.registor_id=@attendantrecord.registor_id
          attendant.teamname=@attendantrecord.teamname
          attendant.player_id=player.id
          attendant.name=player.username
          attendant.email=player.email
          attendant.curscore=player.playerprofile.curscore
          attendant.save

        end
      end 
      send_register_notice_team(@curgroup,@attendantrecord,@type,@curgroup.holdgame.find_allgameholders)
    end
   
  end 

end  
def  send_register_notice_single(curgroup,newofficialattend,type, gameholders)
 if APP_CONFIG['Mailer_delay']
   UserMailer.delay.send_playerschanged_single_gameholder(curgroup, nil, nil,newofficialattend,type,gameholders)
 else
   UserMailer.send_playerschanged_single_gameholder(curgroup, nil, nil,newofficialattend,type,gameholders).deliver 
 end 
end
def  send_register_notice_double(curgroup,newattendantrecord,playerlist,type,gameholders)
 if APP_CONFIG['Mailer_delay']
     UserMailer.send_playerschanged_double_gameholder(curgroup, newattendantrecord,playerlist,type,gameholders).deliver 

    #UserMailer.delay.send_playerschanged_double_gameholder(curgroup, newattendantrecord,playerlist,type)
 else
   UserMailer.send_playerschanged_double_gameholder(curgroup, newattendantrecord,playerlist,type,gameholders).deliver 
 end 
end
def  send_register_notice_team(curgroup,newattendantrecord,type,gameholders)
 if APP_CONFIG['Mailer_delay']
   UserMailer.send_playerschanged_team_gameholder(curgroup, nil, nil,newattendantrecord,type,gameholders).deliver 
 else
   UserMailer.send_playerschanged_team_gameholder(curgroup, nil, nil,newattendantrecord,type,gameholders).deliver 
 end 
end

def  send_cancel_notice_single(curgroup, cancelled_player_id,cancelled_palyer_name,newofficialattend,type,gameholders)
if APP_CONFIG['Mailer_delay']
  UserMailer.delay.send_playerschanged_single_gameholder(curgroup,cancelled_player_id,cancelled_palyer_name, newofficialattend,type,gameholders)
else
  UserMailer.send_playerschanged_single_gameholder(curgroup, cancelled_player_id,cancelled_palyer_name, newofficialattend,type,gameholders).deliver
end  
       
  if newofficialattend
     if APP_CONFIG['Mailer_delay']
       UserMailer.delay.send_backup_to_official_single(curgroup, newofficialattend)
     else

       UserMailer.send_backup_to_official_single(curgroup, newofficialattend).deliver
     end
  end
     
end
def  send_cancel_notice_double(curgroup,newofficialattend, cancelledplayerlist, type,gameholders)

if APP_CONFIG['Mailer_delay']
  #UserMailer.delay.send_playerschanged_double_gameholder(curgroup, newofficialattend, playerlist,type)
  UserMailer.delay.send_playerschanged_double_gameholder(curgroup, newofficialattend,cancelledplayerlist,type,gameholders)
else
  UserMailer.send_playerschanged_double_gameholder(curgroup, newofficialattend,cancelledplayerlist,type,gameholders).deliver
end     
  if newofficialattend
     if APP_CONFIG['Mailer_delay']
       UserMailer.delay.send_backup_to_official_double(curgroup, newofficialattend)
     else

       UserMailer.send_backup_to_official_double(curgroup, newofficialattend).deliver
     end
  end
     
end
def  send_cancel_notice_team(curgroup,cancelled_teamname,  cancelledplayerlist, newofficialattend,type,gameholders)

if APP_CONFIG['Mailer_delay']
    UserMailer.delay.send_playerschanged_team_gameholder(curgroup,cancelled_teamname, cancelledplayerlist, newofficialattend,type,gameholders)
else
  UserMailer.send_playerschanged_team_gameholder(curgroup,cancelled_teamname,  cancelledplayerlist, newofficialattend,type,gameholders).deliver
end  
       
  if newofficialattend
     if APP_CONFIG['Mailer_delay']
      UserMailer.delay.send_backup_to_official_team(curgroup, newofficialattend)
     else
       UserMailer.send_backup_to_official_team(curgroup, newofficialattend).deliver
     end
  end
     
end
def cancel_singleplayer_registration
    @attendantrecord=Groupattendant.find(params[:user_in_groupattendant])
    @curgroup=@attendantrecord.gamegroup
    @attendants=@curgroup.groupattendants
    if ((@curgroup.holdgame.find_allgameholders.include?(current_user) )|| (current_user.has_role? :admin) || (current_user.has_role? :superuser) || ( !@curgroup.cancellation_deadline_flag)) ||
       (Time.now < @curgroup.cancellation_deadline)
       
      if (@attendants.index(@attendantrecord)<@curgroup.noofplayers) && (@attendants.count>=@curgroup.noofplayers+1)
        newofficialattend=@attendants.at(@curgroup.noofplayers).attendants.first
      
      end    
        cancelled_palyer_name= @attendantrecord.attendants.first.name
        cancelled_player_id=@attendantrecord.attendants.first.player_id

        @attendantrecord.destroy
        send_cancel_notice_single(@curgroup, cancelled_player_id,cancelled_palyer_name,newofficialattend,'cancel',@curgroup.holdgame.find_allgameholders)
   
    else
      flash[:warning]="已超過本比賽分組取消報名截止時間,若欲取消報名,請電主辦人辦理!"

    end    
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@curgroup.id})
end 
def cancel_double_registration

    @attendantrecord=Groupattendant.find(params[:user_in_groupattendant])
    @curgroup=@attendantrecord.gamegroup
    @groupattendants=@curgroup.groupattendants
    if ((@curgroup.holdgame.find_allgameholders.include?(current_user) )|| (current_user.has_role? :admin) || (current_user.has_role? :superuser) || ( !@curgroup.cancellation_deadline_flag)) ||
       (Time.now < @curgroup.cancellation_deadline)

      if (@groupattendants.index(@attendantrecord)<@curgroup.noofplayers) && (@groupattendants.count>=@curgroup.noofplayers+1)
        @newofficialattend=@groupattendants.at(@curgroup.noofplayers)
     
      end
      @cancelledplayerlist=Array.new
      for attendant in @attendantrecord.attendants   
        tempplayer=Hash.new   
        tempplayer['name']=attendant.name
        tempplayer['player_id']=attendant.player_id
        tempplayer['curscore']=attendant.curscore
        @cancelledplayerlist.push(tempplayer)   
       end
      @attendantrecord.destroy

      send_cancel_notice_double(@curgroup,@newofficialattend, @cancelledplayerlist,'cancel',@curgroup.holdgame.find_allgameholders)
    else
      flash[:warning]="已超過本比賽分組取消報名截止時間,若欲取消報名,請電主辦人辦理!"

    end 
    #Attendant.where(:groupattendant_id=>params[:user_in_groupattendant],:player_id=>params[:player_id]).first.destroy
    #@attendantrecord.destroy
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@curgroup.id})
end
def cancel_singleplayer_registration_inteam

   
    @attendantrecord=Groupattendant.find(params[:user_in_groupattendant])
    @curgroup=@attendantrecord.gamegroup
    @tempattendant=Attendant.where(:groupattendant_id=>params[:user_in_groupattendant],:player_id=>params[:player_id]).first.destroy
    #@attendantrecord.destroy
    send_register_notice_team(@curgroup,@attendantrecord,'playerschanged',@curgroup.holdgame.find_allgameholders)
 
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@curgroup.id})
end
def cancel_team_registration
     
    @attendantrecord=Groupattendant.find(params[:user_in_groupattendant])
    @curgroup=@attendantrecord.gamegroup
    @groupattendants=@curgroup.groupattendants
    @cancelled_teamname=@attendantrecord.teamname

    if ((@curgroup.holdgame.find_allgameholders.include?(current_user) )|| (current_user.has_role? :admin) || (current_user.has_role? :superuser) || ( !@curgroup.cancellation_deadline_flag ||
       (Time.now < @curgroup.cancellation_deadline)))
      
      if (@groupattendants.index(@attendantrecord)<@curgroup.noofplayers) && (@groupattendants.count>=@curgroup.noofplayers+1)
        @newofficialattend=@groupattendants.at(@curgroup.noofplayers)
     
      end
      @cancelledplayerlist=Array.new
      for attendant in @attendantrecord.attendants  
        tempplayer=Hash.new   
        tempplayer['name']=attendant.name
        tempplayer['player_id']=attendant.player_id
        tempplayer['curscore']=attendant.curscore
        @cancelledplayerlist.push(tempplayer) 
      end
    #@tempattendant=Attendant.where(:groupattendant_id=>params[:user_in_groupattendant],:player_id=>params[:player_id]).first.destroy
      @attendantrecord.destroy
      send_cancel_notice_team(@curgroup, @cancelled_teamname, @cancelledplayerlist, @newofficialattend, 'cancel', @curgroup.holdgame.find_allgameholders) 
    else
      flash[:warning]="已超過本比賽分組取消報名截止時間,若欲取消報名,請電主辦人辦理!"
    end    
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@curgroup.id})
end


 
def teamplayersinput
  successflag= false
  flash.clear
  @playerlist=Array.new
  @curgroup=Gamegroup.find(params[:format])
  #@playerlist=Array.new #to avoid pass nil array to view 
  if params[:registration]
    if params[:teamname]!=""
       @playerlist=User.where(:id=> params[:playerid].uniq).order_by_ids(params[:playerid].uniq) if params[:playerid]
      #@playerlist=User.find(params[:playerid].uniq) if params[:playerid]
      scoresum=0
      @playerlist.each do |player|
        scoresum+=player.playerprofile.curscore
      end 
      
      if(!@curgroup.check_double_team_meet_group_score_qualify(scoresum))
        flash[:alert]='該組積分總和不符合本分組資格，無法接受報名!' 
      else
        successflag=true
        teamregistration(params[:format], @playerlist, params[:teamname],nil)
      end
    else
        @playerlist=User.where(:id=> params[:playerid].uniq).order_by_ids(params[:playerid].uniq) if params[:playerid]
       #@curgroup=Gamegroup.find(params[:format])
       flash[:alert]='隊名不得為空白!請重新輸入'
    end 
                        
    elsif params[:quit]
      #@curgroup=Gamegroup.find(params[:format])
    
    elsif params[:getplayerfromuser] 
      if !params[:playerid] || params[:playerid].length<20
         @playerlist=User.where(:id=> params[:playerid].uniq).order_by_ids(params[:playerid].uniq) if params[:playerid]
         #@curgroup=Gamegroup.find(params[:format])
         @teamname=params[:teamname]
        if params[:keyword] 
          @newplayer=get_inputplayer(params[:playerid],params[:keyword])
      
          if @newplayer  
            @playerlist.push(@newplayer)
          end  
        else
          flash[:alert]='球友資料皆不為空白!請重新輸入'
        end 
      else
         @playerlist=User.where(:id=> params[:playerid].uniq).order_by_ids(params[:playerid].uniq) if params[:playerid]
         @curgroup=Gamegroup.find(params[:format])
         flash[:alert]='團隊球員不得超過20位!'
      end  
    end 
    
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@curgroup.id}) if (params[:registration]&&params[:teamname]!="" && successflag )  || params[:quit] || successflag      
end
def teamplayersadd
  successflag= false
  @curgroup=Gamegroup.find(params[:format])
  flash.clear
   if params[:name]=='add'
      @groupattendant_id=params[:row_group].to_i
      @teamname=Groupattendant.find(params[:row_group].to_i).teamname
      teamplayer_ids=params[:teamarray].collect{|s| s.to_i}
      curplayers=Attendant.find(teamplayer_ids).collect(&:player_id)
      #@playerlist=User.find( curplayers)
       @playerlist=User.where(:id=> curplayers).order_by_ids(curplayers) 
   else
     @groupattendant_id=params[:groupattendantid]
     @playerlist=Array.new #to avoid pass nil array to view
    end  
  if params[:registration]
    if params[:teamname]!=""
       @playerlist=Array.new
       @playerlist=User.where(:id=> params[:playerid]).order_by_ids(params[:playerid]) if params[:playerid]

       @playerscorelist=Array.new
       scoresum=0
       @playerlist.each do |player|
         scoresum+=player.playerprofile.curscore
       end  
   
       if(!@curgroup.check_double_team_meet_group_score_qualify(scoresum))
           flash[:alert]='該組積分總和不符合本分組資格，無法接受更改或新增!' 
         else
          successflag=true
          teamregistration(params[:format], @playerlist, params[:teamname],params[:groupattendantid])
        end
    else
       @playerlist=User.where(:id=> params[:playerid].uniq).order_by_ids(params[:playerid].uniq) if params[:playerid]
     
       flash[:alert]='隊名不得為空白!請重新輸入'
    end 
                        
    elsif params[:quit]
      @curgroup=Gamegroup.find(params[:format])
    
    elsif params[:getplayerfromuser] 
      if !params[:playerid] || params[:playerid].length<20
         @playerlist=User.where(:id=> params[:playerid].uniq).order_by_ids(params[:playerid].uniq) if params[:playerid]
         @teamname=params[:teamname]
        if params[:keyword] 
          @newplayer=get_inputplayer(params[:playerid],params[:keyword])
      
          if @newplayer  
            @playerlist.push(@newplayer)
          end  
        else
          flash[:alert]='球友資料皆不為空白!請重新輸入'
        end 
      else
         @playerlist=User.find(params[:playerid].uniq) if params[:playerid]
         flash[:alert]='團隊球員不得超過20位!'
      end  
    end 
    
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@curgroup.id}) if (params[:registration]&&params[:teamname]!="" && successflag)  || params[:quit]      
end

def singleplayerinput
  flash.clear
  @playerlist=Array.new #to avoid pass nil array to view 
  if params[:registration]
     singleregistration(params[:format], params[:playerid].uniq)
     
                        
    elsif params[:quit]
      @curgroup=Gamegroup.find(params[:format])
    
    elsif params[:getplayerfromuser] 
      @playerlist=User.where(:id=> params[:playerid]).order_by_ids(params[:playerid]) if params[:playerid]
      @curgamegroupid=params[:format]
      @curgroup=Gamegroup.find(params[:format])
      if params[:keyword] 
        @newplayer=get_inputplayer(params[:playerid],params[:keyword])
      
        if @newplayer  
           @playerlist.push(@newplayer)
        end  
      else
        flash[:alert]='球友資料皆不為空白!請重新輸入'
      end 
   
    end 
    
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@curgroup.id}) if params[:registration] || params[:quit]      
end
def get_inputplayer(playerlist,keyword)

  if !keyword
     flash[:alert]='球友資料不得有空白!請重新輸入!'
     return nil
  end
  reg = /^\d+$/
  if ! reg.match(keyword)
    @newplayer = User.where(:username=>keyword).first
  else
    @newplayer=User.find_by_id(keyword.to_i).first 
  end  
  if !@newplayer 
          flash[:alert] = "無此球友資料，請查明後再輸入!" 
  elsif check_in_blacklist(@newplayer.id)
          flash[:alert] = @newplayer.username+"已被本賽事主辦人列為黑名單,無法報名本賽事！"         
  elsif(@curgroup.findplayer(@newplayer.id))
          flash[:alert] = "此球友已經完成報名，請勿重覆報名!"
  elsif (@curgroup.check_regsitered_same_timeframe_group(@newplayer))
         flash[:alert] = @newplayer.username+"此球友已經報名相同時段之其他場賽事,所以無法報名本賽事！需取消其他場賽事報名,才可報名本賽事" 
  elsif playerlist && playerlist.include?(@newplayer.id.to_s)
          flash[:alert]="此球友("+@newplayer.id.to_s+","+@newplayer.username+")已經輸入，請勿重覆輸入!"
  elsif !(@curgroup.check_single_meet_group_score_qualify(@newplayer.playerprofile.curscore)&&@curgroup.check_player_meet_group_cert(@newplayer)) 
          flash[:alert] = "此球友("+@newplayer.id.to_s+","+@newplayer.username+","+@newplayer.playerprofile.curscore.to_s+ ")不符合此分組參賽資格，無法報名此分組比賽!"  
  
  elsif !@newplayer.phone && current_user!=@curgroup.holdgame.gameholder.user
        flash[:alert] = "此球友("+@newplayer.id.to_s+","+@newplayer.username+ ")之電話號碼為空白,請用變更資料功能輸入電話號碼後才能報名"
      
  else
    return @newplayer    
  end
  return nil      
end  

def doubleplayersinput
  flash.clear
  @playerlist=Array.new #to avoid pass nil array to view 
  if params[:registration]
    doubleregistration(params[:format], params[:playerid])
     
                        
    elsif params[:quit]
      @curgroup=Gamegroup.find(params[:format])
    
    elsif params[:getplayerfromuser] 

      @playerlist=Array.new
      #@playerlist=User.find(params[:playerid]) if params[:playerid]
      @playerlist=User.where(:id=> params[:playerid]).order_by_ids(params[:playerid]) if params[:playerid]#to keep same order
      @curgamegroupid=params[:format]
      @curgroup=Gamegroup.find(params[:format])

      if(params[:keyword1] && params[:keyword2])
        @newplayer1=get_inputplayer(params[:playerid],params[:keyword1])
        @newplayer2=get_inputplayer(params[:playerid],params[:keyword2])
        if @newplayer1 && @newplayer2
            if !(@curgroup.check_player_meet_group_cert(@newplayer1) && @curgroup.check_player_meet_group_cert(@newplayer2))
              flash[:notice]='該組有球員不符合本分組資格，無法接受報名!'

            elsif( !@curgroup.check_double_team_meet_group_score_qualify(@newplayer1.playerprofile.curscore+@newplayer2.playerprofile.curscore))
              flash[:notice]='該組積分總和不符合本分組資格，無法接受報名!' 
            else
              @playerlist.push( @newplayer1)
              @playerlist.push( @newplayer2)
            end
        end
        
      else
 
         flash[:alert]='因為是雙打賽,輸入兩位球友資料皆不得有空白!請重新輸入' 
      end  
      
    end 
    
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@curgroup.id}) if params[:registration] || params[:quit]      
   
end
def show

  @gamegroup = @holdgame.gamegroups.find( params[:format] )
  @groupttendee= @gamegroup.groupattendants
  @attendee =@gamegroup.allgroupattendee
end

def new
 
  @gamegroup = @holdgame.gamegroups.build
  @gamegroup.starttime=@holdgame.startdate.to_date
  @gamegroup.scorelow=0
  @gamegroup.scorehigh=2500

end

def create
  @gamegroup = @holdgame.gamegroups.build( params[:gamegroup] )
  if @gamegroup.save
  
     redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@gamegroup.id}) 
  else
    render :action => :new
  end
end

def edit
  @gamegroup = @holdgame.gamegroups.find( params[:id] )
  @gamegroup.starttime= @gamegroup.starttime.in_time_zone.strftime("%F %H:%M")
  @gamegroup.cancellation_deadline= @gamegroup.cancellation_deadline.in_time_zone.strftime("%F %H:%M") if @gamegroup.cancellation_deadline
  @gamegroup.registration_deadline= @gamegroup.registration_deadline.in_time_zone.strftime("%F %H:%M") if @gamegroup.registration_deadline


end

def update
  @gamegroup = @holdgame.gamegroups.find( params[:format] )

  if @gamegroup.update_attributes( params[:gamegroup] )
    redirect_to  holdgame_gamegroups_path(@holdgame, {:targroupid=>@gamegroup.id}) 
  else
    render :action => :edit
  end

end

def destroy
  @gamegroup = @holdgame.gamegroups.find( params[:id] )
  @gamegroup.groupattendants.delete_all
  @gamegroup.destroy

  redirect_to holdgame_gamegroups_url( @holdgame )
end

def groupdumptoxls

  @player_current_score=Hash.new
  @player_FB=Hash.new
  @gamegroup = @holdgame.gamegroups.find( params[:gamegroup_id] )
  @gamegroup.allgroupattendee.flatten.each do |player|
      if player
         player_info=User.find(player.player_id)
         @player_current_score[player.player_id]=player_info.playerprofile.curscore 
         @player_FB[player.player_id]=player_info.fbaccount
      end   
  end
  @groupttendee= @gamegroup.groupattendants
  @attendee =@gamegroup.allgroupattendee
  filename=@holdgame.gamename+@gamegroup.groupname
  headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xlsx\"" 
  respond_to do |format|
    format.html
    format.xlsx
  end
end  
protected

def find_holdgame
  @holdgame = Holdgame.find( params[:holdgame_id] )
  @gameholder=Gameholder.find( @holdgame.gameholder_id)
  gon.lat=@holdgame.lat
  gon.lng=@holdgame.lng
  gon.courtname=@holdgame.courtname+'--['+@holdgame.address+']'
end

def resolve_layout
    case action_name
    
    when "index" 
      "gamegroup"
    else
      "application"
    end
  end
end
