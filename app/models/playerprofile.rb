# encoding: UTF-8”
require 'google_drive'
class Playerprofile < ActiveRecord::Base
  before_create :add_name
  # attr_accessible :title, :body
  belongs_to :user
  attr_accessible :name, :initscore, :curscore, :totalwongames,  :totallosegames, :lastgamedate, :lastgamename, :lastscoreupdatedate, :gamehistory, :profileurl
  attr_accessible :imageurl, :bio, :paddleholdtype, :paddlemodel, :forwardrubber, :backrubber  , :created_at , :updated_at 
   def add_name
    self.name=self.user.username if !self.name
    if self.initscore!=0
     self.gamehistory=self.user.created_at.to_date.to_s+"("+self.initscore.to_s+")" 
    end 
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
    connection = GoogleDrive.login(APP_CONFIG['Google_Account'], APP_CONFIG['Google_PWD'])
    spreadsheet = connection.spreadsheet_by_url(fileurl)
    @playerlistsheet=spreadsheet.worksheets[0]
    @playerlist= Array.new
    
    (2..@playerlistsheet.num_rows).each do |i|
      #binding.pry
      @playerlistsheet[i,1]=i-1
      if @playerlistsheet[i,2]!='?'
        @player=User.find_by_id(@playerlistsheet[i,2].to_i)
        if @player
          @playerlistsheet[i,3]=@player.username
          @playerlistsheet[i,5]=@player.fbaccount
          if @player.playerprofile.curscore
            @playerlistsheet[i,4]=@player.playerprofile.curscore
          else
            @playerlistsheet[i,4]=@player.playerprofile.initscore
          end  
        end  
        @playerinfo=Hash.new
        @playerinfo['serial']=i-1
        @playerinfo['id']=@playerlistsheet[i,2]
        @playerinfo['name']=@playerlistsheet[i,3]
        @playerinfo['curscore']=@playerlistsheet[i,4]
        @playerinfo['fbaccount']=@playerlistsheet[i,5]
        @playerlist.push(@playerinfo)
      end 
    end  
      @playerlistsheet.save()
      @playerlist
  end
  def self.import
        #Playerprofile.delete_all(conditions = nil)
        #User.delete_all(conditions = nil)
        #connection = GoogleDrive.login("lttf.taiwan@gmail.com", "allen7240")
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
          #@profile.imageurl=@ws[i,12]
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
