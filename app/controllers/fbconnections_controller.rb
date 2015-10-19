#encoding: UTF-8”
class FbconnectionsController < ApplicationController

  def removefbconnect
  	current_user.authorizations.destroy_all
  	flash[:notice]='已取消FB帳號連結'
   	redirect_to  :back
  end
  def resetfbconnect
  	current_user.authorizations.destroy_all
  	user_omniauth_authorize_path('facebook')
  	
  	redirect_to  :back
  end	
end
