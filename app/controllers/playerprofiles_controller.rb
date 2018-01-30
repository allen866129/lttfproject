# encoding: UTF-8;”

require 'google/api_client'
require 'google/api_client/client_secrets'
require 'google/api_client/auth/installed_app'
class PlayerprofilesController < ApplicationController
  before_filter :authenticate_user!  ,:find_user, :except=>[:show,:create,:index, :import, :lttfindex, :search]
  helper_method :sort_column, :sort_direction
  layout :resolve_layout
  # GET /playerprofiles
  # GET /playerprofiles.json
  def lttfindex
  end
  def index
       
   #@playerprofiles = Playerprofile.all
     @playerprofiles = Playerprofile.includes(:user).order(sort_column + " " + sort_direction).page(params[:page]).per(50)
     @membercount=Playerprofile.all.size
     respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @playerprofiles }
    end
  end

  def search
    reg = /^\d+$/
    if params[:keyword]
      if ! reg.match(params[:keyword].strip)
            @playerprofiles = Playerprofile.includes(:user).where( [ "name like ?", "%#{params[:keyword].strip}%" ]).order(sort_column + " " + sort_direction).page( params[:page] ).per(50)

      else
        @playerprofiles=Array.new
        @tempid=params[:keyword].to_i
        @playerprofiles = Playerprofile.includes(:user).where( :user_id => @tempid).order(sort_column + " " + sort_direction).page( params[:page] ).per(50)

      end 
    
    end  
   # @playerprofiles = Playerprofile.where( [ "name like ?", "%#{params[:keyword]}%" ]).page( params[:page] ).per(100)
    render :action => :index
  end 
  def batchaccountsinput
    Playerprofile.batch_create_account
    redirect_to  :back
    
  end
  def googleplayerlist
    if params[:playerlistfileurl]
      @players=Playerprofile.googleplayerlist(params[:playerlistfileurl])
      @previousfileurl=params[:playerlistfileurl]
    else
       @players=[] 
       @previousfileurl=nil
    end  
    
  end

 
  def show
   
    session[:player_id] = params[:id]
    @playerprofile = Playerprofile.find(params[:id])

    @showgames=@playerprofile.user.set_future_games_showdata  

    opts   = { :width => 700, :height => 400, :title =>  '積分走勢圖', :legend => 'bottom' }
    @chart = GoogleVisualr::Interactive::LineChart.new(@playerprofile.get_score_data_table, opts)
    #binding.pry
    #@chart=@playerprofile.get_score_data_table

    @GameTable=@playerprofile.get_played_games_table(params[:page])
    #if @GameTable.present?
    #  unless @GameTable.kind_of?(Array)
    #   @GameTable = @GameTable.page(params[:page]).per(20)
    #  else
    #   @GameTable = Kaminari.paginate_array(@GameTable).page(params[:page]).per(20)
    #  end
    #end 

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @playerprofile }
    end
   
  end
  
  # GET /playerprofiles/new
  # GET /playerprofiles/new.json
  def new

    @playerprofile  = current_user.build_playerprofile
     format.html { redirect_to @playerprofile, notice: 'Playerprofile was successfully new.' }
      respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @playerprofile }
    end
  end

  # GET /playerprofiles/1/edit
  def edit
    @playerprofile = Playerprofile.find(params[:id])
    @user=@playerprofile.user
  end

  # POST /playerprofiles
  # POST /playerprofiles.json
  def create
  
  @playerprofile = current_user.playerprofile.build(params[:playerprofile])
  #@playerprofile = Playerprofile.where( :user_id => current_user.id).first
  @playerprofile.name=current_user.username
  @playerprofile.lastscoreupdatedate=current.user.created_at.to_date
  @playerprofile.curscore=@playerprofile.initscore
  

    respond_to do |format|
      if @playerprofile.save
        format.html { redirect_to @playerprofile, notice: 'Playerprofile was successfully created.' }
        format.json { render json: @playerprofile, status: :created, location: @playerprofile }
      else
        format.html { render action: "new" }
        format.json { render json: @playerprofile.errors, status: :unprocessable_entity }
      end
    end
   end

  # PUT /playerprofiles/1
  # PUT /playerprofiles/1.json
  def update
    @playerprofile = Playerprofile.find(params[:id])

    respond_to do |format|
      if @playerprofile.update_attributes(params[:playerprofile])
        format.html { redirect_to @playerprofile, notice: 'Playerprofile was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @playerprofile.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /playerprofiles/1
  # DELETE /playerprofiles/1.json
  def destroy
    @playerprofile = Playerprofile.find(params[:id])
    @playerprofile.destroy

    respond_to do |format|
      format.html { redirect_to playerprofiles_url }
      format.json { head :no_content }
    end
  end
  def import
     Playerprofile.import
     flash[:notice] = "event was successfully updated"
     redirect_to root_url, notice: "Lttfplayers imported."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_playerprofile
      @playerprofile = Playerprofile.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def playerprofile_params
      params.require(:playerprofile).permit(:user_id, :name, :initscore, :curscore, :totalwongames,  :totallosegames, :lastgamedate, :lastscoreupdatedate, :gamehistory, 
                       :profileurl, :imageurl, :bio, :paddleholdtype, :paddlemodel, :forwardrubber, :backrubber )
    end

    def find_user
    @event = User.find( current_user.id )
    end
  def resolve_layout
    case action_name
    
    when "lttfindex" 
      "lttfhome"
    else
      "application"
    end
  end
  private
  
    def sort_column
      Playerprofile.column_names.include?(params[:sort]) ? params[:sort] : "user_id"
    end
  
    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
