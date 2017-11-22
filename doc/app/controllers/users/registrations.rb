class Users::RegistrationsController < Devise::RegistrationsController
def create
    super
    if resource.save 
     UserMailer.registration_confirmation(resource).deliver
     	
    end 
end
def update
  super
end
end