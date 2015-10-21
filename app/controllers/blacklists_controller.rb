# encoding: UTF-8”

class BlacklistsController < ApplicationController
  # GET /blacklists
  # GET /blacklists.json
  def index

    if !params[:gameholder]
      @viewgameholder_user=User.find(current_user.id)
      @blacklists= @viewgameholder_user.gameholder.blacklists.order('playerprofile_id').page(params[:page]).per(50)
      @current_gameholder_id=@viewgameholder_user.id
      @current_gameholder_name=  @viewgameholder_user.username      
    elsif params[:gameholder].to_i==0
      @blacklists = Blacklist.order('gameholder_id').order('playerprofile_id').page(params[:page]).per(50)
      @current_gameholder_name=""
      @current_gameholder_id=0
     # @current_gameholder=0
    else
      @viewgameholder_user=User.find(params[:gameholder].to_i)
      @blacklists= @viewgameholder_user.gameholder.blacklists.order('playerprofile_id').page(params[:page]).per(50)
      @current_gameholder_name=  @viewgameholder_user.username 
      @current_gameholder_id=@viewgameholder_user.id
      #@current_gameholder=params[:gameholder].to_i
    end


    @membercount=@blacklists.size
    @gameholders=Gameholder.all
    @gameholder_lists=@gameholders.collect{|g| [g.user.username, g.user.id]}
    @gameholder_lists.unshift(['全部主辦人',0])   
  
  end
 def blacklistsearch

    reg = /^\d+$/
    if params[:keyword]
      if ! reg.match(params[:keyword].strip)
            user= User.find_by_name(params[:keyword].strip).first

      else
            user=User.find_by_id(params[:keyword].to_i).first
          
      end 
      @playerprofile= user.playerprofile if user
      if @playerprofile
        @viewer_gameholder_flag=false
        if (current_user) && (current_user.has_role? :gameholder)
          @viewer_gameholder_flag=true

        if current_user.gameholder.blacklists.find{|p| p.playerprofile_id==user.id}
          @already_in_user_blacklists=true
        else
          @already_in_user_blacklists=false
        end  
       
      end        
        @showgames=@playerprofile.user.set_future_games_showdata  

        opts   = { :width => 700, :height => 400, :title =>  '積分走勢圖', :legend => 'bottom' }
        @chart = GoogleVisualr::Interactive::LineChart.new(@playerprofile.get_score_data_table, opts)
    #binding.pry
    #@chart=@playerprofile.get_score_data_table

        @GameTable=@playerprofile.get_played_games_table(params[:page])
  
        render "playerprofiles/show" and return
      
      end
      
        
    end  
     redirect_to( blacklists_path, :gamholder=>current_user.id, :notice => "找不到該球員資料請重新輸入！") and return
#                      ^^^^^ This calls the index method

  end 
 
  # GET /blacklists/1
  # GET /blacklists/1.json
  def show
    @blacklist = Blacklist.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @blacklist }
    end
  end

  # GET /blacklists/new
  # GET /blacklists/new.json
  def new
    @blacklist = Blacklist.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @blacklist }
    end
  end

  # GET /blacklists/1/edit
  def edit
    @blacklist = Blacklist.find(params[:id])
  end

  # POST /blacklists
  # POST /blacklists.json
  def create
    @blacklist = Blacklist.new(params[:blacklist])

    respond_to do |format|
      if @blacklist.save
        format.html { redirect_to @blacklist, notice: 'Blacklist was successfully created.' }
        format.json { render json: @blacklist, status: :created, location: @blacklist }
      else
        format.html { render action: "new" }
        format.json { render json: @blacklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /blacklists/1
  # PUT /blacklists/1.json
  def update
    @blacklist = Blacklist.find(params[:id])

    respond_to do |format|
      if @blacklist.update_attributes(params[:blacklist])
        format.html { redirect_to @blacklist, notice: 'Blacklist was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @blacklist.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /blacklists/1
  # DELETE /blacklists/1.json
  def destroy
    @blacklist = Blacklist.find(params[:id])
    @blacklist.destroy

    respond_to do |format|
      format.html { redirect_to blacklists_url }
      format.json { head :no_content }
    end
  end
  def toggleblacklist
    @id=params[:player_id].to_i
    if params[:removeblacklist]
      @blacklist=current_user.gameholder.blacklists.find{|p| p.playerprofile_id==@id}
      @blacklist.delete

    end 

    if params[:addblacklist]
      @playerprofile = Playerprofile.find(@id)
      @blacklist=current_user.gameholder.blacklists.build
      @blacklist.playerprofile_id=@id
      @blacklist.player_name=params[:player_name]
      @blacklist.note=params[:note]
      @blacklist.save
    end
    redirect_to blacklists_path 
  end   
end
