# encoding: UTF-8;”
class UploadgamesController < ApplicationController
  respond_to :js, :html
  before_filter :authenticate_user! ,:except=>[:gamescorechecking, :show, :show_player_games ]
  before_filter :authenticate_superuser! , :only=>[:publishuploadgame, :calculategamepage]
   # GET /uploadgames
  # GET /uploadgames.json

  def index
  

    @uploadgames = Uploadgame.waitingforprocess.page(params[:page]).per(10)
   
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @uploadgames }
    end
  end
  
  def gamescorechecking
    @uploadgames = Uploadgame.waitingchecking.page(params[:page]).per(10)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @uploadgames }
    end
  end

  def  send_game_waiting_publish_notice(uploadgame)
    noticelist=find_admins_superusers
    emails =noticelist.map {|a| a.email}
    if APP_CONFIG['Mailer_delay']
      UserMailer.delay.send_game_waiting_publish_notice(emails,uploadgame)
    else
      UserMailer.send_game_waiting_publish_notice(emails,uploadgame).deliver 
    end 
  end 

  def savetoupload
    
   
    @cacheuploadgame=Rails.cache.read(current_user.id.to_s+"curgame")
    Uploadgame.transaction do
      #Uploadgame.waitingforprocess.where(:gamename => @cacheuploadgame.gamename).destroy_all 
      #@uploadgame=Uploadgame.waitingforprocess.where(:gamename => @cacheuploadgame.gamename).first_or_initialize 
      #@uploadgame=Uploadgame.new
      @holdgame=Holdgame.find(params[:holdgame_id])
      @uploadgame= (@holdgame.uploadgame==nil) ? @holdgame.build_uploadgame : @holdgame.uploadgame
      @uploadgame= @cacheuploadgame
      @playerssummery=Rails.cache.read(current_user.id.to_s+"playersummery")
        i=0
        params[:suggestscore].each do |suggestscore|
          @playerssummery[i]["suggestscore"]=suggestscore
          i+=1
        end  
      
      curlines=""
      @playerssummery.each do |player|

        curlines=curlines+ "\n" if curlines!=""   
        curlines=curlines+"_"+player["serial"].to_s 
        curlines=curlines+"_"+player["id"].to_s
        curlines=curlines+"_"+player["name"]
        curlines=curlines+"_"+player["bgamescore"].to_s
        curlines=curlines+"_"+player["wongames"].to_s
        curlines=curlines+"_"+player["losegames"].to_s
        curlines=curlines+"_"+player["agamescore"].to_s
        curlines=curlines+"_"+player["scorechanged"].to_s
        curlines=curlines+"_"+player["suggestscore"].to_s
        curlines=curlines+"_"+player["adjustscore"].to_s
        curlines=curlines+"_"+player["original bscore"].to_s
     
      end
      @uploadgame.players_result= curlines   
      @uploadgame.uploader=current_user.username

      @uploadgame.save! 
    end  
    send_game_waiting_publish_notice(@uploadgame)
    flash[:success] = "檔案上傳成功"
    @uploadgames =  Uploadgame.waitingforprocess.page(params[:page]).per(10)
    redirect_to :action => "index"
  end 

  def upload
    
        
  end

  def displayuploadfile
    
    @uploadgame=Uploadgame.upload(params[:gamefileurl])
    #@uploadgame =  Uploadgame.last
    #@playerssummery=getplayersummary(@uploadgame.players_result)
    #@playerssummery=@NewFoo.uploadplayerinfo
    @playerssummery=@uploadgame.getplayersummary
   
    @gamesrecords=@uploadgame.getdetailgamesrecord
    @autosuggest=@uploadgame.find_system_adjust_score(nil)
    #@gamesrecords=@NewFoo.uploadgamesrecord

    Rails.cache.write(current_user.id.to_s+"curgame", @uploadgame)
    Rails.cache.write(current_user.id.to_s+"playersummery",@playerssummery)
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @uploadgame }
    end
  end  
  def uploadfile_fromholdgame

    @holdgame=Holdgame.find(params[:format])
    
    #@uploadgame=Uploadgame.upload(holdgame.inputfileurl)
    @uploadgame=Uploadgame.upload(@holdgame)
    if @uploadgame.class != Array  #return Arry means found error player 
      @Playerlisterr=false
      @Erroplayerlist=[]
      @playerssummery=@uploadgame.getplayersummary
      @gamesrecords=@uploadgame.getdetailgamesrecord
      @autosuggest=@uploadgame.find_system_adjust_score(nil)

      Rails.cache.write(current_user.id.to_s+"curgame", @uploadgame)
      Rails.cache.write(current_user.id.to_s+"playersummery",@playerssummery)
    else
      @Erroplayerlist=@uploadgame
      @Playerlisterr=true
    end  
    

    render :displayuploadfile
  end  

  def getplayersummary(players_result)
    @currentgamesummery= players_result.split(/\n/)
    @playerssummery=Array.new

    @currentgamesummery.each do |playersummery|
      @player=Hash.new
      @dummy,@player["serial"],@player["id"], @player["name"],@player["bgamescore"],@player["wongames"],@player["losegames"],@player["agamescore"],
                @player["scorechanged"],@player["suggestscore"],@player["adjustscore"]= playersummery.split("_")
      @player["id"]=@player["id"].to_i
      @player["bgamescore"]=@player["bgamescore"].to_i
      @player["wongames"]=@player["wongames"].to_i
      @player["losegames"]=@player["losegames"].to_i
      @player["agamescore"]=@player["agamescore"].to_i
      @player["scorechanged"]=@player["scorechanged"].to_i
      @player["suggestscore"]=@player["suggestscore"].to_i
      @player["adjustscore"]=@player["adjustscore"].to_i if @player["adjustscore"]!=nil
      @playerssummery.push(@player)
    end  
    @playerssummery  
  end  

  def getdetailgamesrecord(gameRawinfo)
    gamesrecords=Array.new
    
    if(gameRawinfo)
      detailgamesrecord= gameRawinfo.split("]")
    end  

    detailgamesrecord.each do |singlegamerecord|
    
      singlegame=singlegamerecord.split("|")
      gamesarray=Hash.new
      gamesarray["group"]=singlegame[0]
      players=singlegame[1].split(":")
      gamesarray["Aplayer"]=players[0]
      gamesarray["Bplayer"]=players[1]
      gamesarray["gameresult"]=singlegame[2]
      dummy,gamesarray["detailrecords"] = singlegame[3].split("[")
      gamesrecords.push(gamesarray)
    end
    gamesrecords
  end  
  
  # GET /uploadgames/1
  # GET /uploadgames/1.json
  def show
    @uploadgame = Uploadgame.find(params[:id])
 
    @playerssummery=@uploadgame.getplayersummary
    @gamesrecords=@uploadgame.getdetailgamesrecord
 
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @uploadgame }
    end
  end
  def send_publish_notice_to_players(uploadgame) 
    @playerssummery=uploadgame.getplayersummary
    @gamesrecords=uploadgame.getdetailgamesrecord
    @adjustplayers=set_adjust_players(@playerssummery)
    @adjustplayers=Uploadgame.hash_calculate_score(@adjustplayers, @gamesrecords)

    @playerssummery.each do |player|
      @playergames=@gamesrecords.find_all{|v| (v["Aplayer"]==player["name"])||(v["Bplayer"]==player["name"])}
      @user=User.find(player["id"].to_i)
      @player=player
      if APP_CONFIG['Mailer_delay']
        #UserMailer.gamerecords_publish_notice(@user, @player, @playergames, uploadgame).deliver
        UserMailer.delay.gamerecords_publish_notice(@user, @player, @playergames, uploadgame)
        #UserMailer.gamerecords_publish_notice(@user, @player, @playergames, uploadgame).deliver
      else  
        UserMailer.gamerecords_publish_notice(@user, @player, @playergames, uploadgame).deliver
      end
    end  
    
     UserMailer.gamerecords_publish_notice_to_FB( uploadgame).deliver if APP_CONFIG['HOST_TYPE']=='server'
  end

  def send_publish_notice_to_gameholders(uploadgame)
    gameholderlist=Array.new
    gameholderlist.push(uploadgame.holdgame.gameholder) if uploadgame.holdgame
    emails =gameholderlist.uniq.map {|a| a.email}

    if APP_CONFIG['Mailer_delay']
        #UserMailer.gamerecords_publish_notice(@user, @player, @playergames, uploadgame).deliver
        UserMailer.delay.send_publish_notice_to_gameholders(emails, uploadgame) if !emails.empty?
      else  
        UserMailer.send_publish_notice_to_gameholders(emails, uploadgame).deliver if !emails.empty?
    end
  end 
  def publishuploadgame
  
    @uploadgame = Uploadgame.find(params[:game_id])
    @playerssummery=@uploadgame.getplayersummary
    @gamesrecords=@uploadgame.getdetailgamesrecord
  
    @adjustplayers=set_adjust_players(@playerssummery)
    @adjustplayers=Uploadgame.hash_calculate_score(@adjustplayers, @gamesrecords)
    @autosuggest=@uploadgame.find_system_adjust_score(@adjustplayers)
    @zeroscoreplayers= @adjustplayers.find_all{|v| (v["bgamescore"].to_i==0 ||v["bgamescore"]=="") && (v["adjustscore"]==nil ||v["adjustscore"]=="") && !(v["wongames"]==0 && v["losegames"]==0)}
     flash[:alert]="尚有0積分球友，需賦予調整積分才可進行積分公告作業!"  if  @zeroscoreplayers!=[]
     Rails.cache.write(current_user.id.to_s+"curgame", @uploadgame)
     Rails.cache.write(current_user.id.to_s+"playersummery",@playerssummery)
     Rails.cache.write(current_user.id.to_s+"gamesrecords",@gamesrecords)
     Rails.cache.write(current_user.id.to_s+"adjustplayers",@adjustplayers)
     Rails.cache.write(current_user.id.to_s+"autosuggest", @autosuggest)
           
end

def send_updatescore_notice_to_gameholders(newgame,uploadgame)
    gameholderlist=Array.new
    gameholderlist.push(uploadgame.holdgame.gameholder) if uploadgame.holdgame
    emails =gameholderlist.uniq.map {|a| a.email}
    if APP_CONFIG['Mailer_delay']
        #UserMailer.gamerecords_publish_notice(@user, @player, @playergames, uploadgame).deliver
        UserMailer.delay.send_updatescore_notice_to_gameholders(emails, newgame) if !emails.empty?
      else  
        UserMailer.send_updatescore_notice_to_gameholders(emails, newgame).deliver if !emails.empty?
    end
end 
def updategamescore_to_main_table (uploadgame, inp_adjustplayers)
    adjustplayers= inp_adjustplayers.find_all{|v| !(v["wongames"]==0 && v["losegames"]==0) }
   
    playersadjusted= Array.new
    curlines=""
    date = DateTime.now
    User.transaction do
      adjustplayers.each  do |player|
       
        @player=User.find(player["id"].to_i)
        if player["bgamescore"]!= player["original bscore"]  #賽前積分不等候原來績分,表示需前作調整
          if @player.playerprofile.initscore ==0        #初始積分為0,前置調整當作賦予初始積分不是前置調整
            @player.playerprofile.initscore=player["bgamescore"].to_i 
            predate=date-1
            @player.playerprofile.gamehistory=predate.to_date.to_s+"("+player["bgamescore"].to_s+")" #將initscore設定時間提前一天,讓趨勢圖更容易顯示
          else
            curlines=curlines+ "\n" if curlines!=""   
            curlines=curlines+"_"+player["id"].to_s
            curlines=curlines+"_"+player["name"]
            curlines=curlines+"_"+player["original bscore"].to_s
            curlines=curlines+"_"+"0"
            curlines=curlines+"_"+"0"
            curlines=curlines+"_"+player["bgamescore"].to_s
            scorechange=player["bgamescore"].to_i-player["original bscore"].to_i
            curlines=curlines+"_"+scorechange.to_s
            @player.playerprofile.curscore=player["agamescore"].to_i
            @player.playerprofile.lastscoreupdatedate =date.to_date.to_s
            @player.playerprofile.gamehistory=@player.playerprofile.gamehistory+"\n"+date.to_date.to_s+"("+player["agamescore"].to_s+")" 
         
          end
          @player.save 
          @playerscore=player 
          if APP_CONFIG['Mailer_delay']
             #UserMailer.adjustscore_publish_notice(@player,@playerscore,@uploadgame).deliver
             UserMailer.delay.adjustscore_publish_notice(@player,@playerscore,@uploadgame)
          else  
            UserMailer.adjustscore_publish_notice(@player,@playerscore,@uploadgame).deliver
          end  
        end
      end
    end
    if curlines !=""
      @adjustgame=Game.new
      @adjustgame.gamedate=date.to_date.to_s
      @adjustgame.gamename=uploadgame.gamename+"前置調整"
      @adjustgame.players_result=curlines
      @adjustgame.uploader="LTTF"
      @adjustgame.save
    end  
    @newgame=Game.new
    @newgame.gamename=uploadgame.gamename
    @newgame.detailgameinfo=uploadgame.detailgameinfo
    @newgame.uploader=uploadgame.uploader
    curlines=""
    User.transaction do
      adjustplayers.each  do |player|
        if !(player["wongames"]==0 && player["losegames"]==0) 
          curlines=curlines+ "\n" if curlines!=""   
          curlines=curlines+"_"+player["id"].to_s
          curlines=curlines+"_"+player["name"]
          curlines=curlines+"_"+player["bgamescore"].to_s
          curlines=curlines+"_"+player["wongames"].to_s
          curlines=curlines+"_"+player["losegames"].to_s
          curlines=curlines+"_"+player["agamescore"].to_s
          curlines=curlines+"_"+player["scorechanged"].to_s
          @player=User.find(player["id"])
          @player.playerprofile.curscore=player["agamescore"].to_i

          @player.playerprofile.totalwongames =0 if !@player.playerprofile.totalwongames
          @player.playerprofile.totalwongames+=player["wongames"].to_i
          @player.playerprofile.totallosegames =0 if !@player.playerprofile.totallosegames
          @player.playerprofile.totallosegames+=player["losegames"].to_i
          @player.playerprofile.lastgamedate =uploadgame.gamedate
          @player.playerprofile.lastgamename =uploadgame.gamename
          @player.playerprofile.lastscoreupdatedate =date.to_date.to_s

          if @player.playerprofile.gamehistory==nil 
            if player["initscore"]!=0
              @player.playerprofile.gamehistory= @player.playerprofile.created_at.to_date.to_s+"("+ @player.playerprofile.initscore.to_s+")" 
              @player.playerprofile.gamehistory=@player.playerprofile.gamehistory+"\n"+date.to_date.to_s+"("+player["agamescore"].to_s+")" 
            else
               @player.playerprofile.gamehistory=date.to_date.to_s+"("+player["agamescore"].to_s+")" 
            end 
          else
               @player.playerprofile.gamehistory=@player.playerprofile.gamehistory+"\n"+date.to_date.to_s+"("+player["agamescore"].to_s+")" 
          end  

          @player.save
          @playerscore=player
          if APP_CONFIG['Mailer_delay']
            UserMailer.delay.newscore_publish_notice(@player,@playerscore,@uploadgame.gamename)
          else  
            UserMailer.newscore_publish_notice(@player,@playerscore,@uploadgame.gamename).deliver
          end  
        end
      end
    end
     @newgame.players_result=curlines  
     @newgame.save
     Gsheet4game.recycle(uploadgame.holdgame.id)
     #tempid=uploadgame.holdgame.id
     #@Gsheet=Gsheet4game.find_by_holdgameid(tempid).first
     #@Gsheet.in_use=false if @Gsheet
     #@Gsheet.save
     send_updatescore_notice_to_gameholders(@newgame,uploadgame)
     UserMailer.newscore_publish_notice_to_FB( @newgame).deliver if APP_CONFIG['HOST_TYPE']=='server' 
  end  
   def publish_trycalculation
   # @uploadgame = Uploadgame.find(params[:game_id])
    @uploadgame=Rails.cache.read(current_user.id.to_s+"curgame")
    @playerssummery=Rails.cache.read(current_user.id.to_s+"playersummery")
    @gamesrecords=Rails.cache.read(current_user.id.to_s+"gamesrecords")
    @adjustplayers=Rails.cache.read(current_user.id.to_s+"adjustplayers")
    
    #params[:adjustscores].each do |adjustscore|
    @adjustplayers.each_with_index do |adjustplayer,i|  
      adjustplayer["adjustscore"]=params[:adjustscores][i]
      adjustplayer["bgamescore"]=adjustplayer["original bscore"]
 
    end  

    @adjustplayers=set_adjust_players(@adjustplayers)
    @updategamesrecords=Uploadgame.gamesrecords_with_scorechanged(@adjustplayers, @gamesrecords)
    @uploadgame.detailgameinfo=Uploadgame.combine_gamerecords(@updategamesrecords)
    @adjustplayers=Uploadgame.hash_calculate_score(@adjustplayers, @updategamesrecords)
    @autosuggest=@uploadgame.find_system_adjust_score(@adjustplayers)

    #@zeroscoreplayers= @adjustplayers.find_all{|v| v["bgamescore"].to_i==0 ||v["bgamescore"]=="" }
    @zeroscoreplayers= @adjustplayers.find_all{|v| (v["bgamescore"].to_i==0 ||v["bgamescore"]=="") && (v["adjustscore"]==nil ||v["adjustscore"]=="") && !(v["wongames"]==0 && v["losegames"]==0)}
    flash[:notice]="積分試算完成!"
    flash[:alert]="尚有0積分球友，需賦予調整積分才可進行積分更新作業!"  if  @zeroscoreplayers!=[]
    Rails.cache.write(current_user.id.to_s+"adjustplayers",@adjustplayers)
    Rails.cache.write(current_user.id.to_s+"curgame", @uploadgame)
    Rails.cache.write(current_user.id.to_s+"playersummery",@playerssummery)
   if params[:save_option_a]

       render :publishuploadgame
       
    end
   
    if params[:save_option_b]
        @uploadgame.updatePlayerResultFromadjustPlayersinfo(@adjustplayers)
        @uploadgame.publishedforchecking = true
        @uploadgame.save
        send_publish_notice_to_players(@uploadgame)
        send_publish_notice_to_gameholders(@uploadgame)
        @uploadgames = Uploadgame.waitingforprocess.page(params[:page]).per(10)
        flash[:success]="本賽事公告作業完成!"
    
      redirect_to :action => "index"
    end
   
  end
  def trycalculation
   # @uploadgame = Uploadgame.find(params[:game_id])
    @uploadgame=Rails.cache.read(current_user.id.to_s+"curgame")
    @playerssummery=Rails.cache.read(current_user.id.to_s+"playersummery")
    @gamesrecords=Rails.cache.read(current_user.id.to_s+"gamesrecords")
    @adjustplayers=Rails.cache.read(current_user.id.to_s+"adjustplayers")
    @autosuggest=Rails.cache.read(current_user.id.to_s+"autosuggest")
   
    #params[:adjustscores].each do |adjustscore|
    @adjustplayers.each_with_index do |adjustplayer,i|  
      adjustplayer["adjustscore"]=params[:adjustscores][i]
      adjustplayer["bgamescore"]=adjustplayer["original bscore"]
        
    end  
    @adjustplayers=set_adjust_players(@adjustplayers)
    @updategamesrecords=Uploadgame.gamesrecords_with_scorechanged(@adjustplayers, @gamesrecords)
    @uploadgame.detailgameinfo=Uploadgame.combine_gamerecords(@updategamesrecords)
    @adjustplayers=Uploadgame.hash_calculate_score(@adjustplayers, @updategamesrecords)
    @autosuggest=@uploadgame.find_system_adjust_score(@adjustplayers)
    #@zeroscoreplayers= @adjustplayers.find_all{|v| v["bgamescore"].to_i==0 ||v["bgamescore"]=="" }
    @zeroscoreplayers= @adjustplayers.find_all{|v| (v["bgamescore"].to_i==0 ||v["bgamescore"]=="") && (v["adjustscore"]==nil ||v["adjustscore"]=="") && !(v["wongames"]==0 && v["losegames"]==0)}
    flash[:notice]="積分試算完成!"
    flash[:alert]="尚有0積分球友，需賦予調整積分才可進行積分更新作業!"  if  @zeroscoreplayers!=[]
    Rails.cache.write(current_user.id.to_s+"adjustplayers",@adjustplayers)
    Rails.cache.write(current_user.id.to_s+"curgame", @uploadgame)
    Rails.cache.write(current_user.id.to_s+"playersummery",@playerssummery)
    Rails.cache.write(current_user.id.to_s+"gamesrecords",@updategamesrecords)
   if params[:save_option_a]

       render :calculategamepage 
       
    end
    if params[:save_option_b]
        Uploadgame.transaction do
          @uploadgameinDB = Uploadgame.waitingforprocess.find_by_id( @uploadgame.id)
          if @uploadgameinDB
            updategamescore_to_main_table(@uploadgame,@adjustplayers)
            #@uploadgame = Uploadgame.find( @uploadgame.id)
            @uploadgameinDB.scorecaculated =true
            @uploadgameinDB.save
          end
        end
        @uploadgames = Uploadgame.waitingforprocess.page(params[:page]).per(10)
        flash[:success]="積分更新作業完成!"
        redirect_to :action => "index"
    end
   
  end
  def displayupload_show_player_games
    @uploadgame=Rails.cache.read(current_user.id.to_s+"curgame")
    #@playerssummery=Rails.cache.read("playersummery")
    @playerssummery=@uploadgame.getplayersummary
    @playerssummery=@playerssummery.find_all{|v| v['name']==params[:player_name]}
    @gamesrecords=@uploadgame.getdetailgamesrecord
    @gamesrecords=@gamesrecords.find_all{|v| v['Aplayer']==params[:player_name]||v['Bplayer']==params[:player_name]}
    @targetplayername=params[:player_name]
  end  
  def show_player_games
    @uploadgame = Uploadgame.find(params[:format].to_i)
    @playerssummery=@uploadgame.getplayersummary
    @playerssummery=@playerssummery.find_all{|v| v['name']==params[:player_name]}
    @gamesrecords=@uploadgame.getdetailgamesrecord
    @gamesrecords=@gamesrecords.find_all{|v| v['Aplayer']==params[:player_name]||v['Bplayer']==params[:player_name]}
    @targetplayername=params[:player_name]
  end  
  def cal_show_player_games
   @uploadgame=Rails.cache.read(current_user.id.to_s+"curgame")
    @playerssummery=Rails.cache.read(current_user.id.to_s+"playersummery")
    @gamesrecords=Rails.cache.read(current_user.id.to_s+"gamesrecords")
    @adjustplayers=Rails.cache.read(current_user.id.to_s+"adjustplayers")
    @gamesrecords=Uploadgame.gamesrecords_with_scorechanged(@adjustplayers, @gamesrecords)
    
    @playerssummery=@adjustplayers.find_all{|v| v['name']==params[:player_name]}
    #@gamesrecords=@uploadgame.getdetailgamesrecord
    @gamesrecords=@gamesrecords.find_all{|v| v['Aplayer']==params[:player_name]||v['Bplayer']==params[:player_name]}
    @targetplayername=params[:player_name]
  end 
  def publish_show_player_games
    @uploadgame=Rails.cache.read(current_user.id.to_s+"curgame")
    @playerssummery=Rails.cache.read(current_user.id.to_s+"playersummery")
    @gamesrecords=Rails.cache.read(current_user.id.to_s+"gamesrecords")
    @adjustplayers=Rails.cache.read(current_user.id.to_s+"adjustplayers")
    #@uploadgame = Uploadgame.find(params[:format].to_i)
    #@playerssummery=@uploadgame.getplayersummary
    @gamesrecords=Uploadgame.gamesrecords_with_scorechanged(@adjustplayers, @gamesrecords)
    
    @playerssummery=@adjustplayers.find_all{|v| v['name']==params[:player_name]}
    #@gamesrecords=@uploadgame.getdetailgamesrecord
    @gamesrecords=@gamesrecords.find_all{|v| v['Aplayer']==params[:player_name]||v['Bplayer']==params[:player_name]}
    @targetplayername=params[:player_name]
  end 
  def set_adjust_players(playersinfo)
    @adjustplayers = Array.new
    playersinfo.each do |player|
      adjustplayer= Hash.new()
      adjustplayer = player
      adjustplayer["serial"]=player["serial"]
      adjustplayer["id"]=player["id"]
      adjustplayer["name"]=player["name"]
      adjustplayer["original bscore"]=player["original bscore"]

      if (player["adjustscore"]!="" && player["adjustscore"]!=nil && player["adjustscore"].to_i!=0 )
         adjustplayer["bgamescore"]=player["adjustscore"].to_i 
      else

         adjustplayer["bgamescore"]=player["bgamescore"].to_i 
      end   
      adjustplayer["wongames"]=0
      adjustplayer["losegames"]=0
      adjustplayer["scorechanged"]=0
      adjustplayer["agamescore"]=0
      adjustplayer["suggestscore"]=player["suggestscore"].to_i if (player["suggestscore"]!="" && player["suggestscore"]!=nil&& player["suggestscore"].to_i!=0)
      adjustplayer["adjustscore"]=player["adjustscore"].to_i if (player["adjustscore"]!="" && player["adjustscore"]!=nil && player["adjustscore"].to_i !=0 )
      @adjustplayers.push(adjustplayer)    
    end  
    @adjustplayers
  end  

  def calculategamepage
     @uploadgame = Uploadgame.find(params[:game_id])
     @playerssummery=@uploadgame.getplayersummary
     @gamesrecords=@uploadgame.getdetailgamesrecord
    
     @adjustplayers=set_adjust_players(@playerssummery)
     @updategamesrecords=Uploadgame.gamesrecords_with_scorechanged(@adjustplayers, @gamesrecords)
     @uploadgame.detailgameinfo=Uploadgame.combine_gamerecords(@updategamesrecords)
     @adjustplayers=Uploadgame.hash_calculate_score(@adjustplayers, @updategamesrecords)
     @autosuggest=@uploadgame.find_system_adjust_score(@adjustplayers)
     @zeroscoreplayers= @adjustplayers.find_all{|v| (v["bgamescore"].to_i==0 ||v["bgamescore"]=="") && (v["adjustscore"]==nil ||v["adjustscore"]=="") && !(v["wongames"]==0 && v["losegames"]==0)}
     flash[:alert]="尚有0積分球友，需賦予調整積分才可進行積分更新作業!"  if  @zeroscoreplayers!=[]
     Rails.cache.write(current_user.id.to_s+"curgame", @uploadgame)
     Rails.cache.write(current_user.id.to_s+"playersummery",@playerssummery)
     Rails.cache.write(current_user.id.to_s+"gamesrecords",@updategamesrecords)
     Rails.cache.write(current_user.id.to_s+"adjustplayers",@adjustplayers)
     Rails.cache.write(current_user.id.to_s+"autosuggest",@autosuggest)
  end   
  # GET /uploadgames/new
  # GET /uploadgames/new.json
  def new
    @uploadgame = Uploadgame.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @uploadgame }
    end
  end

  # GET /uploadgames/1/edit
  def edit
    @uploadgame = Uploadgame.find(params[:id])
  end

  # POST /uploadgames
  # POST /uploadgames.json
  def create
    @uploadgame = Uploadgame.new(params[:uploadgame])

    respond_to do |format|
      if @uploadgame.save
        format.html { redirect_to @uploadgame, notice: 'Uploadgame was successfully created.' }
        format.json { render json: @uploadgame, status: :created, location: @uploadgame }
      else
        format.html { render action: "new" }
        format.json { render json: @uploadgame.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /uploadgames/1
  # PUT /uploadgames/1.json
  def update
    @uploadgame = Uploadgame.find(params[:id])

    respond_to do |format|
      if @uploadgame.update_attributes(params[:uploadgame])
        format.html { redirect_to @uploadgame, notice: 'Uploadgame was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @uploadgame.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /uploadgames/1
  # DELETE /uploadgames/1.json
  def destroy
    @uploadgame = Uploadgame.find(params[:id])
    @uploadgame.destroy

    respond_to do |format|
      format.html { redirect_to uploadgames_url }
      format.json { head :no_content }
    end
  end
end
