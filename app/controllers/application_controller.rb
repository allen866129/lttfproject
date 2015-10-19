class ApplicationController < ActionController::Base
 
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
 protect_from_forgery with: :exception
def authenticate_admin_user!
 redirect_to new_user_session_path unless current_user && (current_user.has_role? (:admin))
end
def authenticate_superuser!
 redirect_to new_user_session_path unless current_user && ((current_user.has_role? (:superuser)) || (current_user.has_role? (:admin)))
end
def execute_delay_job
# Runs all available jobs and then exits
   # system "./script/delayed_job run "

   # system ("RAILS_ENV=#{Rails.env} #{Rails.root.join('script','delayed_job')} stop >> log/delayed_rake.log")
    system ("RAILS_ENV=#{Rails.env} #{Rails.root.join('script/','delayed_job')} >> log/delayed_rake.log")
end
def  find_admins_superusers 
    admins = Role.find_by_name('admin').users
    superusers=Role.find_by_name('superuser').users
    admins_superusers=(admins+superusers).uniq
    admins_superusers
end
end