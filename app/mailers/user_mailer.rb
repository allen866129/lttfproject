  # encoding: UTF-8;”
  class UserMailer < ActionMailer::Base
  default :from => "lttfadmin@twlttf.org"
  default :content_type => 'text/html'

  require 'koala'
  def sendgamenotice(holdgame,player,subject,message)

    @player=player
    @holdgame=holdgame
    @message=message
    mail(:to => "#{player.name} <#{player.email}>", :subject =>subject)
  end
  def autogamenotice(holdgame,player)

    @player=player
    @gamename=holdgame.startdate.to_s+holdgame.gamename
    @holdgame=holdgame
    mail(:to => "#{player.name} <#{player.email}>", :subject =>"桌球愛好者聯盟#{@gamename}出賽提醒通知")
  end

  def send_game_waiting_publish_notice(emails,uploadgame)
   
    @gamename=uploadgame.gamename
    @uploadgame=uploadgame
    
    mail(:to => emails, :subject =>"桌球愛好者聯盟#{@gamename}比賽成績上傳通知") 
  end

  def send_gameholder_waiting_approve_notice(emails,gameholder)
     @gameholder=gameholder
     mail(:to => emails, :subject =>"桌球愛好者聯盟積分賽主辦人待審核通知") 
  end

  def send_publish_notice_to_gameholders(emails, uploadgame)
    @gamename=uploadgame.gamename
    @uploadgame=uploadgame 
    mail(:to => emails, :subject =>"桌球愛好者聯盟#{@gamename}公告查核通知") 
  end  
  def send_updatescore_notice_to_gameholders(emails,newgame)
    @gamename=newgame.gamename
    @newgame=newgame
    mail(:to => emails, :subject =>"桌球愛好者聯盟#{@gamename}積分更新通知") 
  end
  def  send_gameholder_approve_notice(gameholder)
     @gameholder=gameholder
     mail(:to => "#{gameholder.user.username} <#{gameholder.user.email}>", :subject =>"桌球愛好者聯盟積分賽主辦人審核通過通知") 
  end  

  def send_playerschanged_single_gameholder(gamegroup,cancelled_player_id,cancelled_palyer_name,newofficial,changetype)
    @gamegroup=gamegroup
    @holdgame=@gamegroup.holdgame
    @gameholder=@holdgame.gameholder.user
    @changetype = changetype
    @cancelled_player_id=cancelled_player_id
    @cancelled_palyer_name=cancelled_palyer_name
    #@cancelplayer=cancelplayer 
    @newofficial=newofficial

    if changetype=='cancel'
      @totalcount=@gamegroup.groupattendants.count #already delete cancelled player
      if @totalcount>@gamegroup.noofplayers
        @officialcount=@gamegroup.noofplayers
        @backupcount=@totalcount-@officialcount
      else
        @officialcount=@totalcount
        @backupcount=0
      end 
      subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"報名球員取消報名通知"
      mail(:to => "#{@gameholder.username} <#{@gameholder.email}>", :subject =>subject) 
    end
    if changetype=='register'
      @totalcount=@gamegroup.groupattendants.count  #registered player already added
      if @totalcount>@gamegroup.noofplayers
        @officialcount=@gamegroup.noofplayers
        @backupcount=@totalcount-@officialcount
      else
        @officialcount=@totalcount
        @backupcount=0
      end 
      subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"新增報名球員通知"
      mail(:to => "#{@gameholder.username} <#{@gameholder.email}>", :subject =>subject)
    end
  end 
  def send_playerschanged_double_gameholder(gamegroup, attendrecord, cancelledplayerlist,changetype)

    @gamegroup=gamegroup
    @holdgame=@gamegroup.holdgame
    @gameholder=@holdgame.gameholder.user
    @changetype = changetype
  
    @totalcount=@gamegroup.groupattendants.count #already delete cancelled player
    if @totalcount>@gamegroup.noofplayers
      @officialcount=@gamegroup.noofplayers
      @backupcount=@totalcount-@officialcount
    else
      @officialcount=@totalcount
      @backupcount=0
    end 

    if changetype=='cancel'
      @cancelledplayerlist=cancelledplayerlist #playerlist is group
      subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"報名隊伍取消報名通知"
      mail(:to => "#{@gameholder.username} <#{@gameholder.email}>", :subject =>subject) 
    end
    if changetype=='register'
      @newplayerlist=attendrecord.attendants #playerlist is group
      subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"新增報名隊伍通知"
      mail(:to => "#{@gameholder.username} <#{@gameholder.email}>", :subject =>subject)
    end

  end 
  def send_playerschanged_team_gameholder(gamegroup,cancelled_team_name,cancelled_palyerlist,newofficial,changetype)
    @gamegroup=gamegroup
    @holdgame=@gamegroup.holdgame
    @gameholder=@holdgame.gameholder.user
    @changetype = changetype

    @totalcount=@gamegroup.groupattendants.count #already delete cancelled player
    if @totalcount>@gamegroup.noofplayers
      @officialcount=@gamegroup.noofplayers
      @backupcount=@totalcount-@officialcount
    else
      @officialcount=@totalcount
      @backupcount=0
    end
    #@cancelplayer=cancelplayer 
    @newattendrecord=newofficial

    if changetype=='cancel'
      @cancelled_teamname=cancelled_team_name
      @cancelledplayerlist=cancelled_palyerlist #playerlist is group=cancelled_palyerlist
      subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"報名隊伍取消報名通知"
      mail(:to => "#{@gameholder.username} <#{@gameholder.email}>", :subject =>subject) 
    end
    if changetype=='register'

      subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"新增報名隊伍通知"
      mail(:to => "#{@gameholder.username} <#{@gameholder.email}>", :subject =>subject)
    end
    if changetype=='playerschanged'
       #playerlist is group
      subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"報名隊伍隊員異動通知"
      mail(:to => "#{@gameholder.username} <#{@gameholder.email}>", :subject =>subject)
    end    
  end 

  def send_backup_to_official_single(gamegroup,newofficial)

    @gamegroup=gamegroup
    @holdgame=@gamegroup.holdgame

    @newofficial=newofficial
    subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"列為正選參賽球員通知"
    mail(:to => "#{newofficial.name} <#{newofficial.email}>", :subject =>subject)
  end 
  def send_backup_to_official_double(gamegroup,newofficial)
    @gamegroup=gamegroup
    @holdgame=@gamegroup.holdgame
    @playerlist=newofficial.attendants
    emails = @playerlist.collect(&:email).join(",")
    subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"列為正選參賽隊伍通知"
    mail(:to => emails, :subject =>subject)
  end  
  def send_backup_to_official_team(gamegroup,newofficial)
    @gamegroup=gamegroup
    @holdgame=@gamegroup.holdgame
    @playerlist=newofficial.attendants
    emails = @playerlist.collect(&:email).join(",")
    subject=@holdgame.startdate.to_s+@holdgame.gamename+"-"+@gamegroup.groupname+"列為正選參賽隊伍通知"
    mail(:to => emails, :subject =>subject)
  end  
  def post_to_LTTF (messagetofb , nameoflink,pathlink)
    
    #oauth_access_token = access_token
    
    image_path = "#{Rails.root}/public/LTTF_logo.png"  #change to your image path
    message = messagetofb # your message
    @testuser=User.find(1)
    access_token=@testuser.authorizations.where(:provider => 'facebook').last.token
    graph = Koala::Facebook::API.new(access_token)
    graph = Koala::Facebook::API.new(access_token )
   
   
  
    graph.put_wall_post(messagetofb, {   
    "link" => "http://www.twlttf.org/lttfproject/uploadgames/gamescorechecking",
    "description" =>"桌盟積分賽成績查核網頁" ,
    "name" =>"桌盟積分賽成績查核網頁",
    "picture" => "http://www.twlttf.org/lttfproject/public/LTTF_logo.png"  },
    APP_CONFIG['LTTF_GROUP_ID']
     )
    
  end           
  def registration_confirmation(user)
    @user = user
    #attachments["LTTF_logo.png"] = File.read("#{Rails.root}/public/LTTF_logo.png")
    mail(:to => "#{user.username} <#{user.email}>", :subject => "桌球愛好者聯盟註冊完成通知")
  end
  def gamerecords_publish_notice ( user , gameplayer, gamesrecords ,uploadgame)

    @user = user
    @gameplayer=gameplayer
    @gamename=uploadgame.gamename
    @gamesrecords=gamesrecords
    @uploadgame=uploadgame

    #attachments["LTTF_logo.png"] = File.read("#{Rails.root}/public/LTTF_logo.png")
    mail(:to => "#{user.username} <#{user.email}>", :subject => "桌球愛好者聯盟#{@gamename}比賽結果查核通知")

  end

  def gamerecords_publish_notice_to_FB ( uploadgame)
    
    @gamename=uploadgame.gamename
    @uploadgame=uploadgame
   
    #attachments["LTTF_logo.png"] = File.read("#{Rails.root}/public/LTTF_logo.png")
    #mail(:to => "lttf.taiwan@gmail.com", :subject => "桌球愛好者聯盟#{gamename}比賽結果查核公告")
    #mail(:to => "allen866129@gmail.com", :subject => "桌球愛好者聯盟#{gamename}比賽結果查核公告")
    @message="桌球愛好者聯盟#{@gamename}比賽成績查核公告\n"+
          "各位盟友，#{@gamename}比賽成績已開始公告查核作業\n"+
           "請參賽盟友儘速前往以下網址查核您的出賽成績。\n"+
           "如果您此次的比賽成績紀錄有誤，請儘速跟桌盟或主辦單位反應更正，以免影響正確的積分計算，謝謝配合。\n"+
           "桌球愛好者聯盟敬上"
    @testuser=User.find(1)
    access_token=@testuser.authorizations.where(:provider => 'facebook').last.token
    graph = Koala::Facebook::API.new(access_token)
    graph.put_wall_post(@message, {   
     # "link" => "http://www.twlttf.org/lttfproject/uploadgames/gamescorechecking",
     #"link" =>gamescorechecking_uploadgames_url,
     "link" =>uploadgame_url(uploadgame),
      "description" =>uploadgame.gamename+"成績查核網頁" ,
      "name" =>uploadgame.gamename+"成績查核網頁" ,
      "picture" => "http://www.twlttf.org/lttfproject/public/LTTF_logo.png"  },
      APP_CONFIG['LTTF_GROUP_ID']
     )
   
  end
  def getscorestring(gamegroup)
    case gamegroup.scorelimitation
      when '無積分限制'
       return '無'
      when '限制高低分' 
        return gamegroup.scorelow.to_s+'~'+gamegroup.scorehigh.to_s 
      when '限制最高分'
        return '小於'+gamegroup.scorehigh.to_s 
      when '限制最低分'
        return '大於'+gamegroup.scorelow.to_s
    end  
   
  end
 # def newholdgame_publish_notice_to_FB ( holdgame,access_token)
   def newholdgame_publish_notice_to_FB ( holdgame) 
    @gamename=holdgame.gamename
    @holdgame=holdgame
    @tempdategame=holdgame.startdate.to_s+holdgame.gamename
    @gameholdername=Gameholder.find(holdgame.gameholder_id).name
    @message="桌球愛好者聯盟新增賽事公告\n"+
          "各位盟友，#{@tempdategame}已開始接受報名。\n"+
          "此項賽事主辦人:#{@gameholdername}\n"+
           "請符合參賽資格且欲參賽之盟友儘速前往以下網址報名。\n"+
           "此項比賽分組如下\n"
          
    @gamegroups = @holdgame.gamegroups
    if !@gamegroups.empty?
        @gamegroups.each do |gamegroup|
          @message=@message+
                   "=======================\n"+
                   "組別:"+gamegroup.groupname+"\n"+
                   "賽制："+gamegroup.grouptype+"\n"+
                   "積分限制："+getscorestring(gamegroup)+"\n"+
                   "報名費用："+gamegroup.gamefee.to_s+"\n"+
                   "預計參賽人數："+gamegroup.noofplayers.to_s+"\n"+
                   "比賽時間："+gamegroup.starttime.strftime("%F %H:%M")+"\n"
        end  
    end  
    #attachments["LTTF_logo.png"] = File.read("#{Rails.root}/public/LTTF_logo.png")
    #mail(:to => "lttf.taiwan@gmail.com", :subject => "桌球愛好者聯盟#{gamename}比賽結果查核公告")
    #mail(:to => "allen866129@gmail.com", :subject => "桌球愛好者聯盟#{gamename}比賽結果查核公告")
    @message=@message+ "桌球愛好者聯盟敬上"
    @testuser=User.find(1)
    access_token=@testuser.authorizations.where(:provider => 'facebook').last.token
    graph = Koala::Facebook::API.new(access_token)
   
   
    graph.put_wall_post(@message, {   
     # "link" => "http://www.twlttf.org/lttfproject/uploadgames/gamescorechecking",
     #"link" =>gamescorechecking_uploadgames_url,
    
     "link" =>holdgame_gamegroups_url(holdgame),
      "description" =>@tempdategame+"報名網頁" ,
      "name" =>@tempdategame+"報名網頁" ,
      "picture" => "http://www.twlttf.org/lttfproject/public/LTTF_logo.png"  },
      APP_CONFIG['LTTF_GROUP_ID']
     )
   
  end
 
  def newscore_publish_notice ( user , gameplayer, gamename)
    @user = user
    @gameplayer=gameplayer
    @gamename=gamename
    
    mail(:to => "#{user.username} <#{user.email}>", :subject => "桌球愛好者聯盟#{@gamename}積分更新通知" )

  end

 def newscore_publish_notice_to_FB ( newgame)
    
    @gamename=newgame.gamename
    @newgame=newgame
    
    #mail(:to => "lttf.taiwan@gmail.com", :subject => "桌球愛好者聯盟#{gamename}積分更新公告")
    #mail(:to => "allen866129@gmail.com", :subject => "桌球愛好者聯盟#{gamename}積分更新公告")
    @message="桌球愛好者聯盟#{@gamename}積分更新公告\n"+
          "各位盟友，#{@gamename}比賽成績完成積分計算及積分更新作業\n"+
          "請參賽盟友可以前往桌盟積分賽網站查詢您最新的積分。\n"+
          "桌球愛好者聯盟敬上"
    @testuser=User.find(1)
    access_token=@testuser.authorizations.where(:provider => 'facebook').last.token
    graph = Koala::Facebook::API.new(access_token )
   
   
  
    graph.put_wall_post(@message, {   
    "link" => game_url(@newgame),
    "description" =>@gamename+"成績紀錄表",
    "name" =>@gamename+"成績紀錄表",
    "picture" => "http://www.twlttf.org/lttfproject/public/LTTF_logo.png"  },
    APP_CONFIG['LTTF_GROUP_ID']
     )  
 # post_to_LTTF(@message,@gamename, gamescorechecking_uploadgames_url,access_token)


  end
  def adjustscore_publish_notice ( user , gameplayer, uploadgame)
    @user = user
    @gameplayer=gameplayer
    @gamename=uploadgame.gamename
    @uploadgame=uploadgame
    @scorechange=gameplayer["adjustscore"].to_i-gameplayer["original bscore"].to_i
    mail(:to => "#{user.username} <#{user.email}>", :subject => "桌球愛好者聯盟#{@gamename}通知")

  end
  def holdgame_cancel_notice(holdgame, player)
    @player=player
    @holdgame=holdgame
    @tempdategame=holdgame.startdate.to_s+holdgame.gamename
    mail(:to => "#{player.name} <#{player.email}>", :subject => "桌球愛好者聯盟#{@tempdategame}賽事取消通知")
  end  
  def holdgame_cancel_notice_to_FB(holdgame)
  
    @tempdategame=holdgame.startdate.to_s+holdgame.gamename
          
    #mail(:to => "lttf.taiwan@gmail.com", :subject => "桌球愛好者聯盟#{gamename}積分更新公告")
    #mail(:to => "allen866129@gmail.com", :subject => "桌球愛好者聯盟#{gamename}積分更新公告")
    @message="桌球愛好者聯盟#{@tempdategame}比賽取消公告\n"+
          "各位盟友，#{@tempdategame}因故取消，特此公告!\n"+
          "請已報名此賽事之球友注意,屆時請勿前往參賽，以免白跑一趟，如有不便請見諒!\n"+
          "桌球愛好者聯盟敬上"
    @testuser=User.find(1)
    access_token=@testuser.authorizations.where(:provider => 'facebook').last.token
    graph = Koala::Facebook::API.new(access_token )
   
   
  
    graph.put_wall_post(@message, {   
    "link" => holdgame_gamegroups_url(holdgame),
    "description" =>@tempdategame+"比賽取消公告",
    "name" =>@tempdategame+"比賽取消公告",
    "picture" => "http://www.twlttf.org/lttfproject/public/LTTF_logo.png"  },
    APP_CONFIG['LTTF_GROUP_ID']
     )  
 # post_to_LTTF(@message,@gamename, gamescorechecking_uploadgames_url,access_token)

  end  
  def holdgame_publish_all_to_FB(message)

          
    #mail(:to => "lttf.taiwan@gmail.com", :subject => "桌球愛好者聯盟#{gamename}積分更新公告")
    #mail(:to => "allen866129@gmail.com", :subject => "桌球愛好者聯盟#{gamename}積分更新公告")
    
    @testuser=User.find(1)
    access_token=@testuser.authorizations.where(:provider => 'facebook').last.token
    graph = Koala::Facebook::API.new(access_token )
   
   
  
    graph.put_wall_post(message, {   
    "link" => lttfgamesindex_gamesmaps_url,
    "description" =>'歡迎球友透過此地圖資訊查詢及報名參加桌盟各項賽事。也歡迎各地球友及教練使用桌盟積分系統舉辦比賽!',
    "name" =>"桌球愛好者聯盟積分賽地圖",
    "picture" => "http://www.twlttf.org/lttfproject/public/LTTF_logo.png"  },
    APP_CONFIG['LTTF_GROUP_ID']
     )  
  end  
end