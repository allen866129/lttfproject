# encoding: UTF-8;”
require 'google_drive'

CREDENTIALS_PATH = Rails.root.join('config','service_account.json').to_s.freeze

class Playerprofile < ActiveRecord::Base
  before_create :add_name
  # attr_accessible :title, :body
  belongs_to :user
  attr_accessible :name, :initscore, :curscore, :totalwongames,  :totallosegames, :lastgamedate, :lastgamename, :lastscoreupdatedate, :gamehistory, :profileurl
  attr_accessible :imageurl, :bio, :paddleholdtype, :paddlemodel, :forwardrubber, :backrubber  , :created_at , :updated_at 
def get_score_data_table
  data_table = GoogleVisualr::DataTable.new
  data_table.new_column('date', '日期')
  data_table.new_column('number', '積分走勢')
  #if  self.gamehistory
  #  @scorechangearray = self.gamehistory.split(/\n/).reject(&:blank?)
  #  data_table.add_rows(@scorechangearray.count)

  #  (1..@scorechangearray.count).each do |i|
  #    @record =@scorechangearray.shift
  #    @gamedate= @record.split("(").first
  #    @gamescore= @record.split("(").last.split(")").first
  #    data_table.set_cell(i-1, 0, @gamedate.to_date)
  #    data_table.set_cell(i-1, 1, @gamescore.to_i)
    
  #  end
  #else
  #  data_table.add_rows(1)
  #  data_table.set_cell(0, 0, self.created_at.to_date)
  #  data_table.set_cell(0, 1, self.initscore)

  #end 

  data_table.add_rows(self.score_trend_arrays.count)
  self.score_trend_arrays.each_with_index do |game, i|
    data_table.set_cell(i, 0, game['date'])
    data_table.set_cell(i, 1, game['score'])
  #    data_table.set_cell(i-1, 1, @gamescore.to_i)
  end  
  #opts   = { :width => 700, :height => 400, :title =>  '積分走勢圖', :legend => 'bottom' }
  #@trendchart = GoogleVisualr::Interactive::LineChart.new(data_table, opts)
  #@trendchart
  data_table
end  
def player_gamelist_without_preadjust
  @gamekeytofind="_"+self.user_id.to_s+"_"+self.name+"_"
  @adjkeyword="前置調整"
  @Gamelist=Game.where("gamename not like ?","%#{ @adjkeyword}%")
          .where("players_result like ?","%#{ @gamekeytofind}%").order('created_at DESC')
  @Gamelist  
end
def prize_2018_player_gamelist_without_preadjust
  @gamekeytofind="_"+self.user_id.to_s+"_"+self.name+"_"
  @adjkeyword="前置調整"
  @Gamelist=Game.where("gamename not like ?","%#{ @adjkeyword}%")
          .where(:id =>1130..1417).where("players_result like ?","%#{ @gamekeytofind}%").order('created_at DESC')
  @Gamelist  
end
def prize_2018_statistic_gamelist
 # qualified_games=self.player_gamelist_without_preadjust.where(:created_at =>APP_CONFIG['award_statistic_start_date']..APP_CONFIG['award_statistic_end_date'])
  qualified_games=self.prize_2018_player_gamelist_without_preadjust
  return qualified_games
end
def prize_2018_statistic_gamelist_count
  prize_2018_statistic_gamelist.count
end
def qualifiedwongames_count 
  won_games_count=0
  self.prize_2018_statistic_gamelist.each do |game|
    playergameresult=game.getplayersummary.find{ |p| p["id"] == self.user.id }
    won_games_count+=playergameresult["wongames"]
  end  
  return won_games_count
end  
def score_trend_arrays
  scoretrend =Array.new
 
  self.player_gamelist_without_preadjust.each do |game|
    @scores =Hash.new
    playergameresult=game.getplayersummary.find{ |p| p["id"] == self.user.id }
    @scores['date']=game.gamedate
    @scores['date']=game.updated_at.to_date if !@scores['date']
    @scores['score']= playergameresult['agamescore']
    scoretrend.insert(0,@scores)
   end 

  @initscores =Hash.new

  if self.initscore 
       @initscores['score']=self.initscore
    else
       @initscores['score']=0
  end   
  if scoretrend.empty? 
     @initscores['date']=self.created_at.to_date
     scoretrend.insert(0,@initscores)
  else
    @initscores['date']=scoretrend[0]['date']-1
    scoretrend.insert(0,@initscores)
  end 
  scoretrend
end
def current_score
  lastgame=self.player_gamelist_without_preadjust.first
  if lastgame 
    playergameresult=lastgame.getplayersummary.find{ |p| p["id"] == self.user.id }
    return playergameresult["agamescore"]
  else
     return self.initscore
  end  
end
def total_won_games_count
  won_games_count=0
  games=self.player_gamelist_without_preadjust
  self.player_gamelist_without_preadjust.each do |game|
    playergameresult=game.getplayersummary.find{ |p| p["id"] == self.user.id }
    won_games_count+=playergameresult["wongames"]
  end  
  return won_games_count
end
def total_lose_games_count
 lose_games_count=0
  games=self.player_gamelist_without_preadjust
  self.player_gamelist_without_preadjust.each do |game|
    playergameresult=game.getplayersummary.find{ |p| p["id"] == self.user.id }
    lose_games_count+=playergameresult["losegames"]
  end  
  return lose_games_count 
end
def player_gamelist
  #include 前置調整
  @gamekeytofind="_"+self.user_id.to_s+"_"+self.name+"_"
  @Gamelist=Game.where("players_result like ?","%#{ @gamekeytofind}%").order('created_at DESC')
  @Gamelist
end

def get_star_numbers

       @Gamelist=self.player_gamelist_without_preadjust
      if @Gamelist.count <5
        return 0
      elsif @Gamelist.count <10 
        return 1
      elsif @Gamelist.count <20 
        return 2
      elsif   @Gamelist.count <50
        return 3  
      elsif   @Gamelist.count <100
        return 4
      else
        return 5            
      end
end 
def get_played_games_table (page_parm)
  #@gamekeytofind="_"+self.user_id.to_s+"_"+self.name+"_"
  #@Gamelist=Game.where("players_result like ?","%#{ @gamekeytofind}%").order('created_at DESC')
  @Gamelist=self.player_gamelist
  @GameTable=Array.new()

      #@GameTable=mda(6,@Gamelist.length)
     
  @Gamelist.each do |gamearray|
    @tempGameTable=Array.new() 
    @tempGameTable.push(gamearray.gamename)
    @currentgamesummery=gamearray.players_result.split(/\n/)
    @playertofind="_"+self.user_id.to_s+"_"
        #@destionsummery=@currentgamesummery.select { |v| v =~ /^#{ @gamekeytofind}/ }
    @destionsummery=@currentgamesummery.select { |v| v =~ /^#{ @playertofind}/ }
    @playergameinfo= @destionsummery[0].split("_")
    (3..7).each do |i|
      @tempGameTable.push(@playergameinfo[i])
    end
    @tempGameTable.push(gamearray.id)
    @tempGameTable.push(self.user_id)
    @GameTable.push(@tempGameTable)
    
  end
      if @GameTable.present?
      unless @GameTable.kind_of?(Array)
       @GameTable = @GameTable.page(page_parm).per(20)
      else
       @GameTable = Kaminari.paginate_array(@GameTable).page(page_parm).per(20)
      end
    end 
  @GameTable   
  
end
def add_name
  self.name=self.user.username if !self.name
  self.id  = self.user_id
  #if self.initscore!=0
  #  self.gamehistory=self.user.created_at.to_date.to_s+"("+self.initscore.to_s+")" 
  #end 
  self.lastscoreupdatedate=self.user.created_at.to_date
  self.curscore=self.initscore
  #self.save
end	
def self.findlastrow(worksheet, targetcol)
  @ws_row=worksheet.num_rows
  loop do 
    break if worksheet[@ws_row,targetcol]!=""
      @ws_row-=1
    end
    @ws_row
end 
def self.googleplayerlist(fileurl)
  
  
  session = GoogleDrive::Session.from_service_account_key(CREDENTIALS_PATH)
  #connection = GoogleDrive.login_with_oauth( client.authorization.access_token)
    #@newgame=Uploadgame.new
  spreadsheet = session.spreadsheet_by_url(fileurl)
  playerlistws=spreadsheet.worksheets[0]
  @playerlistsheet=spreadsheet.worksheets[0]
  @searchplayerlist= Array.new 
  (2..@playerlistsheet.num_rows).each do |i|

      @searchplayerlist.push(@playerlistsheet[i,2].to_i)    

  end
  players= User.find(@searchplayerlist)
  @players=players.sort_by{|p| p.playerprofile[:curscore]}.reverse
  playerlistws[1,1]='序號(排名)'
  playerlistws[1,2]='桌盟編號'
  playerlistws[1,3]='姓名'
  playerlistws[1,4]='目前積分'
  playerlistws[1,5]='累計總勝場數'
  playerlistws[1,6]='累計總敗場數'
  @players.each_with_index do |player,i|
    playerlistws[i+2,1]=i+1
    playerlistws[i+2,2]=player.id
    playerlistws[i+2,3]=player.username
    playerlistws[i+2,4]=player.playerprofile.curscore
    playerlistws[i+2,5]=player.playerprofile.totalwongames
    playerlistws[i+2,6]=player.playerprofile.totallosegames 
  end 
  playerlistws.save
  @players
end
def self.find_playerlist_from_googlesheet_by_name(fileurl)
  
  #connection = GoogleDrive.login_with_oauth( client.authorization.access_token)
    #@newgame=Uploadgame.new
  session = GoogleDrive::Session.from_service_account_key(CREDENTIALS_PATH)  
  spreadsheet = session.spreadsheet_by_url(fileurl)
  playerlistws=spreadsheet.worksheets[0]
  @playerlistsheet=spreadsheet.worksheets[0]
  playerlistws[1,1]='序號(排名)'
  playerlistws[1,2]='桌盟編號'
  playerlistws[1,3]='姓名'
  playerlistws[1,4]='目前積分'
  playerlistws[1,5]='累計總勝場數'
  playerlistws[1,6]='累計總敗場數'
  @foundplayerlist= Array.new 
  @unfoundplayerlist=Array.new
  (2..@playerlistsheet.num_rows).each do |i|
      playerlistws[i,1]=i-1
      @user=User.where( :username=>@playerlistsheet[i,3].lstrip.rstrip).first
      if @user

        playerlistws[i,2]=@user.id
        playerlistws[i,3]=@user.username
        playerlistws[i,4]=@user.playerprofile.curscore
        playerlistws[i,5]=@user.playerprofile.totalwongames
        playerlistws[i,6]=@user.playerprofile.totallosegames 
        @foundplayerlist.push(@user) 

      else
         playerlistws[i,3]=@playerlistsheet[i,3].lstrip.rstrip
         @unfoundplayerlist.push(@playerlistsheet[i,3].lstrip.rstrip)
      end  

  end
  playerlistws.save
  return @foundplayerlist, @unfoundplayerlist
end

def self.batch_create_account
   client = Google::APIClient.new(
         :application_name => 'lttfprojecttest',
          :application_version => '1.0.0')
   #fileid=APP_CONFIG['Inupt_File_Template'].to_s.match(/[-\w]{25,}/).to_s
   
    keypath = Rails.root.join('config','client.p12').to_s
    key = Google::APIClient::KeyUtils.load_from_pkcs12( keypath, 'notasecret')
    client.authorization = Signet::OAuth2::Client.new(
     :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
     :audience => 'https://accounts.google.com/o/oauth2/token',
     :scope => ['https://spreadsheets.google.com/feeds/','https://www.googleapis.com/auth/drive'],
     :issuer => APP_CONFIG[APP_CONFIG['HOST_TYPE']]['Google_Issuer'].to_s,
     :access_type => 'offline' ,
     :approval_prompt=>'force',
     :signing_key => key)
     client.authorization.fetch_access_token!
 
    connection = GoogleDrive.login_with_oauth( client.authorization.access_token)
    #@newgame=Uploadgame.new
    spreadsheet = connection.spreadsheet_by_url("https://docs.google.com/spreadsheets/d/1sg9c40WhAPmAxSjwiDDPPwm9vI9ViT9Fb-kyDOgkroE/edit?usp=sharing")
    ws = spreadsheet.worksheets[0]
    (2..ws.num_rows).each do |j|

         username=ws[j,2]
         initscore=ws[j,3]
         email=ws[j,4]
         phone=ws[j,5]
         password=ws[j,6]
         gender=ws[j,7]
        
 
          if !User.where(:username=>  username).first
            User.transaction do
              @user=User.create( :username=>  username, :password=>password, :password_confirmation =>password, :email => email, :phone=>phone, )
              @user.save
              puts @user
            end
               Playerprofile.transaction do
                  @user.build_playerprofile if !@user.playerprofile
         
                  @profile=@user.playerprofile   
                  @profile.name=@user.username
                  @profile.initscore=initscore
                  @profile.bio=gender
                  @profile.lastscoreupdatedate=Time.zone.now.to_date
                  @profile.save
  
               end  
          end 
      end    
end  
def self.import
  connection = GoogleDrive.login(APP_CONFIG['Google_Account'], APP_CONFIG['Google_PWD'])
  spreadsheet = connection.spreadsheet_by_title("桌球愛好者聯盟球友積分總表")
  pwdsheet = connection.spreadsheet_by_title("球友密碼檔")
  @pwdws=pwdsheet.worksheets[0]
  @ws = spreadsheet.worksheets[0]
  @gamesinfo=spreadsheet.worksheets[1]
       
  Game.delete_all(conditions = nil)
  (2..@gamesinfo.num_rows).each do |j|
    @newgame=Game.where(:gamename=>@gamesinfo[j,2]).first 
    @newgame=Game.new if !@newgame
    @newgame.gamename=@gamesinfo[j,2]
    @newgame.gamedate=@gamesinfo[j,3]
    @newgame.players_result=@gamesinfo[j,4]
    @newgame.uploader=@gamesinfo[j,5]
    @gamefileurl=@gamesinfo[j,6]
    @newgame.originalfileurl=@gamefileurl
    gamespreadsheet = connection.spreadsheet_by_url(@gamefileurl)
    @gamesheet=gamespreadsheet.worksheets[0]

    @row=7
    @datacol=13
    @detailgameinfo=""
    @curline=""
    while ( @gamesheet[@row,@datacol]!="") and (@row<=@gamesheet.num_rows ) do
      @curline= @curline+@gamesheet[@row,@datacol]+"|"+@gamesheet[@row,@datacol+1]+":"+@gamesheet[@row,@datacol+2]+"|"+@gamesheet[@row,@datacol+3]+"|["
      @gamerecords=@gamesheet[@row,@datacol+4].split(/\n/)
      (1..5).each do |k|
        @gamerecord=@gamerecords.shift
        @curline=@curline+@gamerecord
        if k<5
          @curline= @curline+"; "
        else
          @curline= @curline+"]"
        end 
            
      end 

      @row+=1
    end   
    @newgame.detailgameinfo=@curline
    @newgame.save
  end 
          
        ############################################ 
      
       #(2..@ws.num_rows).each do |i|
  (2..@ws.num_rows).each do |i|
       
    @current_id=@ws[i,1].to_i
           
    if @pwdws[i,6].length <4 
                               
      @pwdws[i,6]="1234"
    end    
          #binding.pry
    @email=@ws[i,13].lstrip.rstrip.downcase

    @email ="lttf.taiwan@gmail.com" if @email==""|| @email==nil
    @username=@ws[i,2].lstrip.rstrip
    @pwassword=@pwdws[i,6].lstrip.rstrip
    @User=User.where( :username=>@ws[i,2].lstrip.rstrip , :email => @ws[i,13].lstrip.rstrip.downcase).first 

    if !@User 
      @User=User.create( :username=>  @username, :password=>@pwassword, :password_confirmation =>@pwassword, :email => @email,
             :fbaccount => @ws[i,14] )
      @User.id=i-1 if @User.id==nil
      @User.add_role(:admin) if @User.id==1
      @User.save
    else     
           
      @User.update_attribute(:password, @pwdws[i,6])
      @User.update_attribute(:password_confirmation, @pwdws[i,6])
      @User.save
    end
    @User.build_playerprofile if !@User.playerprofile
         
    @profile=@User.playerprofile   
    @profile.name=@User.username
    @profile.initscore=@ws[i,3]
    @profile.curscore=@ws[i,4]
    @profile.totalwongames=@ws[i,5]
    @profile.totallosegames=@ws[i,6]
    @profile.lastgamedate=@ws[i,7]
    @profile.lastgamename=@ws[i,8]
    @profile.lastscoreupdatedate=@ws[i,9]
    @firstcreatedate=@ws[i,20]

    @initscore=@firstcreatedate+"("+@ws[i,3]+")"
          #@profile.gamehistory=@initscore
    if(@ws[i,10]=="")
      @profile.gamehistory=@initscore
    else
      @profile.gamehistory=@initscore+"\n" +@ws[i,10]
    end   
    @profile.profileurl=@ws[i,11]
    @profile.bio=@ws[i,15]
    @profile.paddleholdtype=@ws[i,16]
    @profile.paddlemodel=@ws[i,17]
    @profile.forwardrubber=@ws[i,18]
    @profile.backrubber=@ws[i,19]
    @profile.save
    end 
  end  
  resourcify

  
end
