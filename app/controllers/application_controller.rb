class ApplicationController < ActionController::Base
 before_filter :configure_permitted_parameters, if: :devise_controller?
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
 protect_from_forgery with: :exception
def authenticate_admin_user!
 redirect_to new_user_session_path unless current_user && (current_user.has_role? (:admin))
end
def authenticate_superuser!
 redirect_to new_user_session_path unless current_user && ((current_user.has_role? (:superuser)) || (current_user.has_role? (:admin)))
end

def  find_admins_superusers 
    admins = Role.find_by_name('admin').users
    superusers=Role.find_by_name('superuser').users
    admins_superusers=(admins+superusers).uniq
    admins_superusers
end
def configure_permitted_parameters
   devise_parameter_sanitizer.permit(:account_update) { |u| u.permit( :id, :playerphoto, :fbaccount, :phone,:email, :password, :password_confirmation, :current_password, 
playerprofile_attributes: [ :id, :name, :initscore, :curscore, :totalwongames,  :totallosegames, :lastgamedate, :lastgamename, :lastscoreupdatedate, :gamehistory, :profileurl, :imageurl, :bio, :paddleholdtype, :paddlemodel, :forwardrubber, :backrubber  , :created_at , :updated_at ]) }

end
end