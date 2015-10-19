# encoding: UTF-8”
class AdvitemsController < ApplicationController
before_filter :authenticate_admin_user!
def index

    @advitems = Advitem.all
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @dvitems }
    end

end

  # GET /gamecoholders/1
  # GET /gamecoholders/1.json
  def show
    @advitem = Advitem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @advitem }
    end
  end

  # GET /gamecoholders/new
  # GET /gamecoholders/new.json
  def new
    @advitem = Advitem.new
    
  end

  # GET /gamecoholders/1/edit
  def edit
    @advitem = Advitem.find(params[:id])
  end

  # POST /gamecoholders
  # POST /gamecoholders.json
  def create
     @advitem = Advitem.new(params[:advitem])
     @advitem.creator_id=current_user.id
    respond_to do |format|
      if @advitem.save
        format.html { redirect_to @advitem, notice: 'advitem was successfully created.' }
        format.json { render json: @advitem, status: :created, location: @advitem }
      else
        format.html { render action: "new" }
        format.json { render json: @advitem.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /gamecoholders/1
  # PUT /gamecoholders/1.json
  def update
    @advitem = Advitem.find(params[:id])

    respond_to do |format|
      if @advitem.update_attributes(params[:advitem])
        format.html { redirect_to @advitem, notice: 'advitem was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @advitem.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /gamecoholders/1
  # DELETE /gamecoholders/1.json
  def destroy
   
    @advitem = Advitem.find(params[:id])
    @advitem.destroy
    redirect_to :action => :index
  end

end

