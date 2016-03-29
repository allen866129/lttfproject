# encoding: UTF-8”

require 'google_drive'
require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
class HoldgamesController < InheritedResources::Base

  before_filter :authenticate_user! , :except=>[:index,:show]
  before_filter :find_gameholder

  def index
   
   if !params[:user]
      @allgames=true  #show all reg games
      #@holdgames=Holdgame.includes(:gameholder).where(:lttfgameflag=>true).where("startdate >= ? ", Time.zone.now.to_date-14).page(params[:page]).per(50)
  
      @holdgames=Holdgame.includes(:gameholder).where(:lttfgameflag=>true).page(params[:page]).per(20).order('startdate DESC').reverse_order
 else
      @allgames=false  #show all current_usr reg games
      #@holdgames=Holdgame.includes(:gameholder).where(:lttfgameflag=>true,:gameholder_id=>params[:user].to_i).where("startdate >= ? ", Time.zone.now.to_date-14).page(params[:page]).per(50)
      @holdgames=Holdgame.includes(:gameholder).where(:lttfgameflag=>true,:gameholder_id=>params[:user].to_i).page(params[:page]).per(20).order('startdate DESC').reverse_order
  
   end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @holdgames }
    end
  end
 
  def show
  	  @holdgame= Holdgame.find(params[:id])
  	  respond_to do |format|
        format.html # show.html.erb
        format.json { render json:@holdgame}
      end
  end 
  def new
  	#@holdgame = Holdgame.new(:gameholder_id => @cur_gameholder.id)
    @holdgame=@cur_gameholder.holdgames.build
    @holdgame.gamedays=1
    @holdgame.sponsors=@cur_gameholder.sponsor
    #@holdgame.url=holdgame_gamegroups_url(@holdgame)
  	 respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @holdgame }
    end
  end	
  def edit
  	 @holdgame = Holdgame.find(params[:id])
  	 respond_to do |format|
       format.html # show.html.erb
       format.json { render json: @holdgame}
     end
  end	
  def create

  	@holdgame = Holdgame.new(params[:holdgame])
    @holdgame.gameholder_id=@cur_gameholder.id
    @holdgame.lttfgameflag =true
    @gameinputfile=create_gameinputfile(@holdgame.startdate.to_s+ @holdgame.gamename)    
    @holdgame.inputfileurl=@gameinputfile.fileulr
  	respond_to do |format|
      if @holdgame.save
        @gameinputfile.holdgame_id=@holdgame.id
        @gameinputfile.save
        format.html { redirect_to holdgame_gamegroups_path(@holdgame), notice: '比賽資料建檔完成!' }
        format.json { render json: @holdgame, status: :created, location: @holdgame }
      else

        flash[:notice] = "比賽資料建檔資料失敗!"

        format.html { render action: "new", notice: '比賽資料建檔資料失敗，請跟管理員連絡辦理!' }
        format.json { render json: @holdgame.errors, status: :unprocessable_entity }
      end
    end
  end	

  def update
    @holdgame = Holdgame.find(params[:id])
    respond_to do |format|
      if @holdgame.update_attributes(params[:holdgame])
        format.html { redirect_to @holdgame, notice: '資料修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" ,notice: '資料修改失敗，請跟管理員連絡辦理!'}
        format.json { render json: @holdgame.errors, status: :unprocessable_entity }
      end
    end
  end

  def send_cancel_notice_to_players(holdgame)

    holdgame.gamegroups.each do |group|
      group.allgroupattendee.flatten.each do |player|
      
        if APP_CONFIG['Mailer_delay']
            UserMailer.delay.holdgame_cancel_notice(holdgame, player) if APP_CONFIG['HOST_TYPE']=='server' 
        else
           UserMailer.holdgame_cancel_notice(holdgame, player).deliver if APP_CONFIG['HOST_TYPE']=='server'
        end  
      end
    end  
     
     UserMailer.holdgame_cancel_notice_to_FB(holdgame).deliver 
  end
  def cancel
    @holdgame = Holdgame.find(params[:format])
    @holdgame.cancel_flag=true
    
      if @holdgame.save
        Gsheet4game.recycle(@holdgame.id)
        flash[:success]='本賽事取消成功.'
        send_cancel_notice_to_players(@holdgame) 
      else
       flash[:error]= '本賽事取消失敗，請跟管理員連絡辦理!'
      
      end
    redirect_to holdgames_url
    
  end
  def destroy
    @holdgame = Holdgame.find(params[:id])
    Gsheet4game.recycle(@holdgame.id)
    @holdgame.destroy

    respond_to do |format|
      format.html { redirect_to holdgames_url }
      format.json { head :no_content }
    end
  end
def publish_all
    holdgames=Holdgame.forgamesmaps.where(:lttfgameflag=>true).where(:cancel_flag=>false).where("enddate >= (?)", Time.zone.now.to_date)
    message="桌盟近期賽事("+Time.zone.now.to_date.to_s+"更新)\n"
    message=message+"所有桌盟積分賽事地圖\n"
    message=message+lttfgamesindex_gamesmaps_url+"\n"
    holdgames.each do |holdgame|
      message=message+"============================================\n"  
      message=message+holdgame.startdate.to_s+holdgame.gamename+"\n"
      message=message+holdgame_gamegroups_url(holdgame)+"\n"
    end  
    UserMailer.holdgame_publish_all_to_FB(message).deliver 
    flash[:success]='已將賽事列表公告至桌盟!'
    redirect_to(:back)
end 
def insert_permission(client, file_id, value)

  drive = client.discovered_api('drive', 'v2')
  new_permission = drive.permissions.insert.request_schema.new({
    'value' => value,
    'type' => 'user',
    'role' => 'owner'
  })
  result = client.execute(
    :api_method => drive.permissions.insert,
    :body_object => new_permission,
    :parameters => { 'fileId' => file_id })
  if result.status == 200
    return result.data
  else
    puts "An error occurred: #{result.data['error']['message']}"
  end
end
def clear_gsheet(client, fileurl)
  begin
    connection = GoogleDrive.login_with_oauth( client.authorization.access_token)
    spreadsheet = connection.spreadsheet_by_url(fileurl)
    (2..spreadsheet.worksheets.count).each do |wsno|
      spreadsheet.worksheets[wsno-1].delete if (wsno-1)>0
    end  
    infows=spreadsheet.worksheets[0]
    (7..infows.max_rows).each do |row|
      infows[row,1]=''
      infows[row,2]=''
      infows[row,3]=''

  end  
    infows.save
  rescue
    puts fileurl
    flash[:notice] = "比賽資料建檔資料失敗(file clean)!請通知管理員處理！"
  end

end  
##
# Rename a file
#
# @param [Google::APIClient] client
#   Authorized client instance
# @param [String] file_id
#   ID of file to update
# @param [String] title
#   New title of file
# @return [Google::APIClient::Schema::Drive::V2::File]
#   File if update, nil otherwise
def rename_file(client, file_id, title)
  drive = client.discovered_api('drive', 'v2')
  result = client.execute(
    :api_method => drive.files.patch,
    :body_object => { 'title' => title },
    :parameters => { 'fileId' => file_id })
  if result.status == 200
    return result.data
  end
  puts "An error occurred: #{result.data['error']['message']}"
  return nil
end
 ##
# Copy an existing file
#
# @param [Google::APIClient] client
#   Authorized client instance
# @param [String] origin_file_id
#   ID of the origin file to copy
# @param [String] copy_title
#   Title of the copy
# @return [Google::APIClient::Schema::Drive::V2::File]
#   The copied file if successful, nil otherwise

def copy_file(client, origin_file_id, copy_title)

  drive = client.discovered_api('drive', 'v2')
  copied_file = drive.files.copy.request_schema.new({
    'title' => copy_title
  })
  result = client.execute(
    :api_method => drive.files.copy,
    :body_object => copied_file,
    :parameters => { 'fileId' => origin_file_id })
  if result.status == 200
    return result.data
  else
    flash[:error]="An error occurred: #{result.data['error']['message']}"
  end
end

def copy_players_list

  holdgame=Holdgame.find(params[:format])
  playerlist=Array.new
  holdgame.gamegroups.each do |gamegroup|
    if !gamegroup.allgroupattendee.empty?
       playerlist +=gamegroup.allgroupattendee.in_groups_of(gamegroup.noofplayers,false)[0].flatten
    end
  end 
  if !playerlist.empty?
    playerlist=playerlist.uniq{|x| x.player_id}  
  end
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
    spreadsheet = connection.spreadsheet_by_url(holdgame.inputfileurl)
    playerlistws=spreadsheet.worksheets[0]
    players_count=playerlistws.num_rows
    keepplayerlist=Array.new
    (1..players_count).each do |row|
      playerlistws[row,1]=nil
      playerlistws[row,2]=nil
     end  
    

    #playerlist=playerlist.sort_by{|e| e[:player_id]}
    playerlistws[1,1]=holdgame.startdate.to_s+holdgame.gamename
    playerlistws[2,1]='比賽日期:'
    playerlistws[2,2]=holdgame.startdate
    playerlistws[3,1]='比賽名稱:'
    playerlistws[3,2]=holdgame.gamename
    playerlistws[4,1]='主辦人員:'
    playerlistws[4,2]=holdgame.gameholder.name
    playerlistws[6,1]='已報名球員名單'
   
    if !playerlist.empty? 
      playerlist.each_with_index do |player,row|
        playerlistws[row+7,1]=row+1
        playerlistws[row+7,2]=player.name
      end
    end
    playerlistws.save
    redirect_to holdgame.inputfileurl
  
end
def get_gameinputfile_from_gsheet4game
  @gmaeinputfile=Gsheet4game.avaliable.first
  
   
end
def create_gameinputfile(filename)
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

  @gsheet=Gsheet4game.available.first
  @gsheet.in_use=true
  fileurl=@gsheet.fileulr
  fileid=fileurl.to_s.match(/[-\w]{25,}/).to_s

  rename_file(client, fileid, filename)
  clear_gsheet(client, fileurl)
  #fileinfo=copy_file(client, fileid, filename)

  #fileinfo.alternateLink
  @gsheet
end
  private
  def find_gameholder

  	@cur_gameholder= Gameholder.where( :user_id=> current_user.id  ).first if current_user
  end	
end
