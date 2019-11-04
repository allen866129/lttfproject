# encoding: UTF-8;”
class GamesmapsController < ApplicationController
  # GET /ttcourts
  # GET /ttcourts.json
  layout :resolve_layout

  def index
    @citiesarray=TWZipCode_hash.keys

    @holdgames=Holdgame.forgamesmaps.where("enddate >= (?)", Time.zone.now.to_date)
    @holdgames= @holdgames.reject {|v| (v.lttfgameflag==true) && (v.gamegroups.count ==0)}
    @geojson = Array.new
    @holdgames.each do |game|
          popup_window_info=render_to_string :partial => "/gamesmaps/my_info", :formats => [:html],:locals => { :holdgame => game}
          @geojson << {
            type: 'Feature',
            geometry: {
              type: 'Point',
              coordinates: [game.lng, game.lat],
              zipcode:game.zipcode

            },
            properties: {
              holder_id: game.gameholder_id,
              gamename: game.gamename,
              gamenote: game.gamenote,
              gametype:gametype,
              startdate:game.startdate,
              enddate:game.enddate,
              contactname:game.contact_name,
              address: game.address,
              playfee: court.playfee, 
              city: game.city,
              county:game.county,
              courtname:game.courtname,
              url:game.url,
              contact_phone: game.contact_phone,
              contact_email: game.contact_email,
              gameinfofile: game.gameinfofile,
              gamedays: game.gamedays,
              sponsors:game.sponsors,
              cancel_flag:game.cancel_flag,
              popup_info: popup_window_info,
              :'marker-color' => '#00607d',
              :'marker-symbol' => 'circle',
              :'marker-size' => 'medium'
            }
          }
        
        end
   
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @holdgames }
    end
  end
 def lttfgamesindex
 @citiesarray=TWZipCode_hash.keys

    #@holdgames=Holdgame.forgamesmaps.where("startdate+gamedays >= ? ", Time.zone.now.to_date).where(:lttfgameflag => true)
    @holdgames=Holdgame.forgamesmaps.where("enddate >= (?)", Time.zone.now.to_date).where(:lttfgameflag => true)
    @holdgames= @holdgames.select {|v| v.gamegroups.count !=0}
    @holdgames_hash=Array.new
    @geojson=Array.new
    @holdgames.each do |game|
          popup_window_info=render_to_string :partial => "/gamesmaps/my_info", :formats => [:html],:locals => { :holdgame => game}
          @geojson << {
            type: 'Feature',
            geometry: {
              type: 'Point',
              coordinates: [game.lng, game.lat],
              zipcode:game.zipcode

            },
            properties: {
              holder_id: game.gameholder_id,
              holder_name: game.gameholder.user.username,
              gamename: game.gamename,
              gamenote: game.gamenote,
              gametype:game.gametype,
              startdate:game.startdate,
              enddate:game.enddate,
              contactname:game.contact_name,
              address: game.address,
              city: game.city,
              county:game.county,
              courtname:game.courtname,
              url:game.url,
              contact_phone: game.contact_phone,
              contact_email: game.contact_email,
              gameinfofile: game.gameinfofile,
              gamedays: game.gamedays,
              sponsors:game.sponsors,
              cancel_flag:game.cancel_flag,
              popup_info: popup_window_info,
              :'marker-color' => '#00607d',
              :'marker-symbol' => 'circle',
              :'marker-size' => 'medium'
            }
          }
        
        end
 
    render :index
 end  
  # GET /ttcourts/1
  # GET /ttcourts/1.json
  def show
    @holdgame = Holdgame.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @holdgame }
    end
  end

  # GET /ttcourts/new
  # GET /ttcourts/new.json
  def new
    gon.action='new'
    @holdgame = Holdgame.new
    @holdgame.gamedays=1
    @citiesarray=TWZipCode_hash.keys
    @countiesarray=TWZipCode_hash[@citiesarray[0]].keys
    @holdgame.address= @citiesarray[0]+@countiesarray[0]
    
    gon.countiesarray=@countiesarray
    gon.twzipecode=TWZipCode_hash

   
    @citiesarray=TWZipCode_hash.keys
    @countiesarray=TWZipCode_hash[@citiesarray[0]].keys
    gon.lat=24
    gon.lng=120.5
    gon.citiesarray=@citiesarray
    gon.areacourts=@ttcourts
    @ttcourts = Ttcourt.all 
    gon.ttcourts=@ttcourts
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

 

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @holdgame }
    end
 
  end

  # GET /ttcourts/1/edit
  def edit
    gon.action='edit'
    @holdgame = Holdgame.find(params[:id])
    @citiesarray=TWZipCode_hash.keys
    gon.citiesarray=@citiesarray
    @countiesarray=TWZipCode_hash[@holdgame.city].keys
    gon.countiesarray=@countiesarray
    gon.twzipecode=TWZipCode_hash
    gon.lat=@holdgame.lat
    gon.lng=@holdgame.lng
    gon.citiesarray=@citiesarray
    @ttcourts = Ttcourt.all 
    gon.areacourts=@ttcourts

    gon.ttcourts=@ttcourts
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
  end

  # POST /ttcourts
  # POST /ttcourts.json
  def create

    @holdgame = Holdgame.new(params[:holdgame])
    @holdgame.gameholder_id = current_user.id #use this field for uploder id not real gameholder_id
    @holdgame.lttfgameflag = false
    respond_to do |format|
      if @holdgame.save
        format.html { redirect_to  gamesmaps_path, notice: @holdgame.gamename+'資料新增成功!' }
        format.json { render json: gamesmaps_path, status: :created, location: @holdgame }
      else
        
        format.html { render action: "new" }
        format.json { render json:@holdgame.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ttcourts/1
  # PUT /ttcourts/1.json
  def update
    @holdgame = Holdgame.find(params[:id])
    @hodgame.gameholder_id = current_user.id #use this field for uploder id not real gameholder_id
    @holdgame.lttfgameflag = false
    respond_to do |format|
      if @holdgame.update_attributes(params[:holdgame])
        format.html { redirect_to  gamesmaps_path, notice: @holdgame.gamename+'資料更新成功!' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @holdgame.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ttcourts/1
  # DELETE /ttcourts/1.json
  def destroy
    @holdgame = Holdgame.find(params[:id])
    @holdgame.destroy

    respond_to do |format|
      format.html { redirect_to gamesmaps_path }
      format.json { head :no_content }
    end
  end
    private

  def resolve_layout
    case action_name
    
    when "index","lttfgamesindex" 
      "gamesmaplayout"
    when "edit" ,"new"
      "gamesmapedit"  
    else
      "application"
    end
  end
end

