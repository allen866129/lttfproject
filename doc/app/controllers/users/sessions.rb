class Users::RegistrationsController < Devise::RegistrationsController
def create
    super

    if resource.save 
      if APP_CONFIG['Mailer_delay']
      	UserMailer.delay.registration_confirmation(resource)
      else
         UserMailer.registration_confirmation(resource).deliver
      end 	
    end 
end
def update
  super
end
end