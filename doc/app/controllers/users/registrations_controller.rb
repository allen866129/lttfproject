class Users::RegistrationsController < Devise::RegistrationsController
def create
    super
    
     @newuser=resource
     #UserMailer.registration_confirmation(resource).deliver
     if APP_CONFIG['Mailer_delay'] 
       UserMailer.delay.registration_confirmation(@newuser) if !resource.errors.any? 
     else
       UserMailer.registration_confirmation(@newuser).deliver if !resource.errors.any? 	
     end
    
end

def update
  super
end


end