# encoding: UTF-8;”
class TtcourtsController < ApplicationController
  # GET /ttcourts
  # GET /ttcourts.json
  layout :resolve_layout

  def index

    @citiesarray=TWZipCode_hash.keys
    @ttcourts = Ttcourt.all
    @ttcourts_hash=Array.new

    @geojson = Array.new
    @ttcourts.each do |court|
          @geojson << {
            type: 'Feature',
            geometry: {
              type: 'Point',
              coordinates: [court.lng, court.lat],
              zipcode:court.zipcode

            },
            properties: {
              name: court.placename,
              address: court.address,
              opentime: court.opentime,
              facilities: court.facilities,
              playfee: court.playfee, 
              city: court.city,
              county:court.county,
              :'marker-color' => '#00607d',
              :'marker-symbol' => 'circle',
              :'marker-size' => 'medium'
            }
          }
        
        end
        
    @ttcourts_views_record=Webpageview.first_or_initialize
    @ttcourts_views_record.ttcourts_views_increment
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @geojson } 
    end
  end

  # GET /ttcourts/1
  # GET /ttcourts/1.json
  def show
 
    @ttcourt = Ttcourt.find(params[:id])
    @ttourt_photos= @ttcourt.courtphotos.all
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @ttcourt }
    end
  end

  # GET /ttcourts/new
  # GET /ttcourts/new.json
  def new
    gon.action='new'
    @ttcourt = Ttcourt.new
    @ttourt_photo= @ttcourt.courtphotos.build
    @citiesarray=TWZipCode_hash.keys
    @countiesarray=TWZipCode_hash[@citiesarray[0]].keys
    @ttcourt.address= @citiesarray[0]+@countiesarray[0]
    @ttcourt.opentime = '待補充'
    @ttcourt.facilities = '待補充'
    @ttcourt.opentime = '待補充' 
    @ttcourt.playfee = '待補充'
    @ttcourt.contactinfo = '待補充'
    @ttcourt.supplyinfo = '待補充'
    @ttcourt.infosource = '網路'
    gon.countiesarray=@countiesarray
    gon.twzipecode=TWZipCode_hash
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @ttcourt }
    end
 
  end

  # GET /ttcourts/1/edit
  def edit
    gon.action='edit'
    @ttcourt = Ttcourt.find(params[:id])
    @ttourt_photos= @ttcourt.courtphotos.all
    @citiesarray=TWZipCode_hash.keys
    gon.citiesarray=@citiesarray
    @countiesarray=TWZipCode_hash[@ttcourt.city].keys
    gon.countiesarray=@countiesarray
    gon.twzipecode=TWZipCode_hash
    gon.lat=@ttcourt.lat
    gon.lng=@ttcourt.lng
  end

  # POST /ttcourts
  # POST /ttcourts.json
  def create

    @ttcourt = Ttcourt.new(params[:ttcourt])
    respond_to do |format|
      if @ttcourt.save
        if params[:ttcourt_courtphotos]
           params[:ttcourt_courtphotos].each do |photo|
           @courtphoto=@ttcourt.courtphotos.build
           @courtphoto.photo =photo
           @courtphoto.save
          end  
        end  
        format.html { redirect_to @ttcourt, notice: @ttcourt.placename+'資料新增成功!' }
        format.json { render json: @ttcourt, status: :created, location: @ttcourt }
      else
        format.html { render action: "new" }
        format.json { render json: @ttcourt.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /ttcourts/1
  # PUT /ttcourts/1.json
  def update
    @ttcourt = Ttcourt.find(params[:id])

    respond_to do |format|
      updateflag=@ttcourt.update_attributes(params[:ttcourt])
      if  updateflag
        if params[:ttcourt_courtphotos]
          params[:ttcourt_courtphotos].each do |photo|
             @courtphoto=@ttcourt.courtphotos.build
             @courtphoto.photo =photo
             @courtphoto.save
           end  
        end  
        format.html { redirect_to @ttcourt, notice: @ttcourt.placename+'資料更新成功!' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @ttcourt.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /ttcourts/1
  # DELETE /ttcourts/1.json
  def destroy
    @ttcourt = Ttcourt.find(params[:id])
    @ttcourt.destroy

    respond_to do |format|
      format.html { redirect_to ttcourts_url }
      format.json { head :no_content }
    end
  end
    private

  def resolve_layout

    case action_name
    
    when "index" 
      "gmapindex"
    when "edit" ,"new"
      "gmapedit"  
    else
      "application"
    end
  end
end
