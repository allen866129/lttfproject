# encoding: UTF-8”
class GamecoholdersController < ApplicationController
  # GET /gamecoholders
  # GET /gamecoholders.json
  def index

    @holdgame = Holdgame.find(params[:format])
    @gamecoholders=@holdgame.gamecoholders
   #respond_to do |format|
   #   format.html # index.html.erb
   #   format.json { render json: @gamecoholders }
   # end
  end

  # GET /gamecoholders/1
  # GET /gamecoholders/1.json
  def show
    @gamecoholder = Gamecoholder.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @gamecoholder }
    end
  end

  # GET /gamecoholders/new
  # GET /gamecoholders/new.json
  def new
    @holdgame = Holdgame.find(params[:format])
    @gamecoholder = @holdgame.gamecoholders.build
    
  end

  # GET /gamecoholders/1/edit
  def edit
    @gamecoholder = Gamecoholder.find(params[:id])
  end

  # POST /gamecoholders
  # POST /gamecoholders.json
  def create
    @gamecoholder = Gamecoholder.new(params[:gamecoholder])

    respond_to do |format|
      if @gamecoholder.save
        format.html { redirect_to @gamecoholder, notice: 'Gamecoholder was successfully created.' }
        format.json { render json: @gamecoholder, status: :created, location: @gamecoholder }
      else
        format.html { render action: "new" }
        format.json { render json: @gamecoholder.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gamecoholders/1
  # PUT /gamecoholders/1.json
  def update
    @gamecoholder = Gamecoholder.find(params[:id])

    respond_to do |format|
      if @gamecoholder.update_attributes(params[:gamecoholder])
        format.html { redirect_to @gamecoholder, notice: 'Gamecoholder was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @gamecoholder.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gamecoholders/1
  # DELETE /gamecoholders/1.json
  def destroy
   
    @gamecoholder = Gamecoholder.find(params[:id])
    holdgame=@gamecoholder.holdgame
    @gamecoholder.destroy
    redirect_to  gamecoholders_path(holdgame)
  end

  def coholderinput
  flash.clear
  @coholderlist=Array.new #to avoid pass nil array to view 
    @holdgame = Holdgame.find(params[:format])   
    if params[:getplayerfromuser] 
       @coholderlist=User.find(params[:playerid].uniq) if params[:playerid]
      if params[:keyword] 
        @newplayer=get_inputplayer(params[:playerid],params[:keyword],@holdgame)
      
        if @newplayer    
          @coholderlist.push(@newplayer) 
        end 
      end
    else
       if params[:registration]
        singleregistration(params[:format], params[:playerid].uniq)
                   
       elsif params[:quit]
         
          #@gamecoholders=@holdgame.gamecoholders
       end 
      redirect_to gamecoholders_path(@holdgame) if params[:registration] || params[:quit]
   end 
     
end
def get_inputplayer(playerlist,keyword,holdgame)
  flash.clear
  if !keyword
     flash[:notice]='球友資料不得有空白!請重新輸入!'
     return nil
  end
  reg = /^\d+$/
  if ! reg.match(keyword)
    @newplayer = User.where(:username=>keyword).first
  else
    @newplayer=User.find_by_id(keyword.to_i)  
  end  
  if !@newplayer 
          flash[:notice] = "無此球友資料，請查明後再輸入!" 
  elsif @newplayer==current_user
    flash[:notice] = "本人已是主辦人!"       
    
  elsif(holdgame.find_gamecoholder(@newplayer.id))
          flash[:notice] = "此球友已經是共同主辦人,請勿重覆輸入!"

  elsif playerlist && playerlist.include?(@newplayer.id.to_s)
          flash[:notice]="此球友("+@newplayer.id.to_s+","+@newplayer.username+")已經輸入，請勿重覆輸入!"
  else
    return @newplayer    
  end
  return nil      
end  
def singleregistration(holdgame_id, playerids)
  
  @holdgame=Holdgame.find(holdgame_id)
 
  @playerlist=Array.new
  @playerlist=User.find(playerids) if playerids

  Gamecoholder.transaction do
    @playerlist.each do |player| 
      gamecoholder= @holdgame.gamecoholders.build 
      gamecoholder.co_holderid=player.id
      gamecoholder.save
      @holdgame.save
    end
   
  end 

end 
end
