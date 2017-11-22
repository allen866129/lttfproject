class Gsheet4gamesController < InheritedResources::Base
  before_filter :authenticate_user! 
  def index

    @gsheet4games = Gsheet4game.order(" created_at DESC").page(params[:page]).per(50)
    @gsheetcount=Gsheet4game.all.size
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @Gsheet4game }
    end
  end
end

