# encoding: UTF-8;”
class AuthcertunitsController < ApplicationController
  # GET /authcertunits
  # GET /authcertunits.json
  def certifyplayerinput

  flash.clear
  @playerlist=Array.new #to avoid pass nil array to view 
    @authcertunit = Authcertunit.find(params[:format])   
    if params[:getplayerfromuser] 
       @playerlist=User.find(params[:playerid].uniq) if params[:playerid]
      if params[:keyword] 
        @newplayer=get_inputplayer(params[:playerid],params[:keyword],@authcertunit)
      
        if @newplayer    
          @playerlist.push(@newplayer) 
        end 
      end
    else
       if params[:certification]
        setplayerscertify(@authcertunit , params[:playerid].uniq)
                   
       elsif params[:quit]
         
          #@gamecoholders=@holdgame.gamecoholders
       end 
      redirect_to authcertunit_path(@authcertunit) if params[:certification] || params[:quit]
   end 
     
  end

  def get_inputplayer(playerlist,keyword,authcertunit)

     flash.clear
     if !keyword
       flash[:error]='球友資料不得有空白!請重新輸入!'
       return nil
     end
     reg = /^\d+$/
     if ! reg.match(keyword)
       @newplayer = User.where(:username=>keyword).first
     else
       @newplayer=User.find(keyword.to_i)  
     end  
     if !@newplayer 
       flash[:error] = "無此球友資料，請查明後再輸入!"      
    
     elsif(authcertunit.users.include?(@newplayer))
       flash[:alert] = "此球友已經被認證過,請勿重覆輸入!"

     elsif playerlist && playerlist.include?(@newplayer.id.to_s)
       flash[:alert]="此球友("+@newplayer.id.to_s+","+@newplayer.username+")已經輸入，請勿重覆輸入!"
     else
       return @newplayer    
     end
     return nil      
   end 
def remove_certification

	certification=Certification.find(params[:certification])
	@authcertunit = Authcertunit.find(params[:format])
    Certification.transaction do
      certification.destroy 	
    end 	

	redirect_to authcertunit_path(@authcertunit)
	
end
def setplayerscertify(authcerunit, playerids)
  
 
 
  @playerlist=Array.new
  @playerlist=User.find(playerids) if playerids

  Certification.transaction do
    @playerlist.each do |player| 
      certification= authcerunit.certifications.build(:user_id => player.id)
      certification.save
    end
   
  end 

end 



  def index
    @authcertunits = Authcertunit.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @authcertunits }
    end
  end

  # GET /authcertunits/1
  # GET /authcertunits/1.json
  def show

    @authcertunit = Authcertunit.find(params[:id])
    @certifications=@authcertunit.certifications
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @authcertunit }
    end
  end

  # GET /authcertunits/new
  # GET /authcertunits/new.json
  def new
    @authcertunit = Authcertunit.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @authcertunit }
    end
  end

  # GET /authcertunits/1/edit
  def edit
    @authcertunit = Authcertunit.find(params[:id])
  end

  # POST /authcertunits
  # POST /authcertunits.json
  def create
    @authcertunit = Authcertunit.new(params[:authcertunit])

    respond_to do |format|
      if @authcertunit.save
        format.html { redirect_to @authcertunit, notice: 'Authcertunit was successfully created.' }
        format.json { render json: @authcertunit, status: :created, location: @authcertunit }
      else
        format.html { render action: "new" }
        format.json { render json: @authcertunit.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /authcertunits/1
  # PUT /authcertunits/1.json
  def update
    @authcertunit = Authcertunit.find(params[:id])

    respond_to do |format|
      if @authcertunit.update_attributes(params[:authcertunit])
        format.html { redirect_to @authcertunit, notice: 'Authcertunit was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @authcertunit.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /authcertunits/1
  # DELETE /authcertunits/1.json
  def destroy
    @authcertunit = Authcertunit.find(params[:id])
    @authcertunit.destroy

    respond_to do |format|
      format.html { redirect_to authcertunits_url }
      format.json { head :no_content }
    end
  end
end
