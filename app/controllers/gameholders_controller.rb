# encoding: UTF-8”
class GameholdersController < InheritedResources::Base
	layout :resolve_layout
	before_filter :authenticate_user! , :except=>[:demos]
  before_filter :find_user, :except=>[:demos]
	def index
    #@playerprofiles = Playerprofile.all
    if (current_user) && ((current_user.has_role? :admin)||(current_user.has_role? :superuser))
       @gameholders = Gameholder.includes(:user).page(params[:page]).per(50)
    else
       @gameholders = Gameholder.alreadyapproved.includes(:user).page(params[:page]).per(50)
    end  

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gameholders }
    end
  end
  def  send_gameholder_approve_notice(gameholder)
    if APP_CONFIG['Mailer_delay']
     UserMailer.delay.send_gameholder_approve_notice(gameholder)
    else
     UserMailer.send_gameholder_approve_notice(gameholder).deliver 
    end 
  end  
  def approve
   @gameholder = Gameholder.find(params[:id])
   @gameholder.approved=true
   @gameholder.save
   @gameholder.user.add_role(:gameholder)
   send_gameholder_approve_notice(@gameholder)
   @gameholders = Gameholder.waitingforapprove.includes(:user).page(params[:page]).per(50) 
   render :action => :approveprocess 
  end  
  def demos
  end  
  def approveprocess
    @gameholders = Gameholder.waitingforapprove.includes(:user).page(params[:page]).per(50) 
      respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @gameholders }
    end  
  end  
  def new
 	  gon.ttcourts=@ttcourts
    @citiesarray=TWZipCode_hash.keys
    @countiesarray=TWZipCode_hash[@citiesarray[0]].keys
   
    gon.areacourts=@ttcourts
    @ttcourts = Ttcourt.all
    @ttcourts_hash=Array.new
    @ttcourts.each do |ttcourt|
      @tempcourt=Hash.new
      @tempcourt['id']=ttcourt.id
      @tempcourt['placename']=ttcourt.placename
      @tempcourt['address']=ttcourt.address
      @tempcourt['lat']=ttcourt.lat
      @tempcourt['lng']=ttcourt.lng
      @ttcourts_hash.push(@tempcourt)
    end  
    @areacourts=@ttcourts.find_all{|v| (v["city"]==@citiesarray[0])&&(v["county"]==@countiesarray[0])}
    @gameholder = current_user.build_gameholder
    #@gameholder.user_id=current_user.id
    @gameholder.name=current_user.username
    @gameholder.email=current_user.email
    @gameholder.address= @citiesarray[0]+@countiesarray[0]
    @gameholder.approved=false
    gon.action='new'
    gon.lat=24
    gon.lng=120.5
    gon.citiesarray=@citiesarray
    gon.countiesarray=@countiesarray
    gon.twzipecode=TWZipCode_hash
    gon.ttcourts=@ttcourts
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @gameholder }
    end
  end
  def show
  	  @gameholder = Gameholder.find(params[:id])
  	  respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gameholder}
    end
  end
  def edit
    @gameholder = Gameholder.find(params[:id])
    @ttcourts = Ttcourt.all
    @ttcourts_hash=Array.new
    @ttcourts.each do |ttcourt|
      @tempcourt=Hash.new
      @tempcourt['id']=ttcourt.id
      @tempcourt['placename']=ttcourt.placename
      @tempcourt['address']=ttcourt.address
      @tempcourt['lat']=ttcourt.lat
      @tempcourt['lng']=ttcourt.lng
      @ttcourts_hash.push(@tempcourt)
    end  
    gon.ttcourts=@ttcourts
    @citiesarray=TWZipCode_hash.keys
    @countiesarray=TWZipCode_hash[@gameholder.city].keys
    @areacourts=@ttcourts.find_all{|v| (v["city"]==@citiesarray[0])&&(v["county"]==@countiesarray[0])}
    gon.areacourts=@ttcourts   
    gon.twzipecode=TWZipCode_hash
    gon.lat=@gameholder.lat
    gon.lng=@gameholder.lng
  end

  def  send_gameholder_waiting_approve_notice(gameholder)
    noticelist=find_admins_superusers
    emails =noticelist.map {|a| a.email}
    if APP_CONFIG['Mailer_delay']
      UserMailer.delay.send_gameholder_waiting_approve_notice(emails,gameholder)
    else
      UserMailer.send_gameholder_waiting_approve_notice(emails,gameholder).deliver 
    end 
  end  

  def create

  @gameholder = Gameholder.new(params[:gameholder])
  #@gameholder.user_id=current_user.id
  #@gameholder.name=current_user.username
  @gameholder.approved=false
  respond_to do |format|
      if @gameholder.save
        send_gameholder_waiting_approve_notice(@gameholder)
        format.html { redirect_to @gameholder, notice: '申請主辦人資料建檔成功!請待審核~' }
        format.json { render json: @gameholder, status: :created, location: @gameholder }
      else
        flash[:notice] = "create failure"

        format.html { render action: "new", notice: '建檔資料失敗，請跟管理員連絡辦理!' }
        format.json { render json: @gameholder.errors, status: :unprocessable_entity }
      end
    end
  end
def update
    @gameholder = Gameholder.find(params[:id])
    respond_to do |format|
      if @gameholder.update_attributes(params[:gameholder])
        format.html { redirect_to @gameholder, notice: '資料修改成功.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gameholder.errors, status: :unprocessable_entity }
      end
    end
  end
  def destroy
    @gameholder = Gameholder.find(params[:id])
    @gameholder.destroy

    respond_to do |format|
      format.html { redirect_to gameholders_url }
      format.json { head :no_content }
    end
  end
   def find_user
    
    if(current_user)
       @currentUser_inGameHolder = Gameholder.where( :user_id=> current_user.id  ).first
    end   
  
  end
     private

  def resolve_layout
    case action_name
    
   
    when "edit" ,"new"
      "gameholderedit"  
    else
      "application"
    end
  end
end


