require 'development_mail_interceptor'
#ActionMailer::Base.smtp_settings = {
#  :address              => "mail.twlttf.org",
#  :port                 => 26, 
#  :domain               => "twlttf.org",
#  :user_name            => "lttfadmin@twlttf.org",
#  :password             => "allen7240",
#  :authentication       => "plain",
#  :enable_starttls_auto => false
#}
#ActionMailer::Base.smtp_settings = {
#  :address              => "box828.bluehost.com",
#  :port                 => 26, 
#  :domain               => "twlttf.org",
#  :user_name            => "lttfadmin@twlttf.org",
#  :password             => "allen7240",
#  :authentication       => "plain",
#  :enable_starttls_auto => false
#}
 

ActionMailer::Base.smtp_settings = {
  :address              =>  APP_CONFIG[APP_CONFIG['HOST_TYPE']]["Mailer_Address"],
  :port                 =>  APP_CONFIG[APP_CONFIG['HOST_TYPE']]["Mailer_Port"].to_i,
  :domain               =>  APP_CONFIG[APP_CONFIG['HOST_TYPE']]["Mailer_Domain"],
  :user_name            =>  APP_CONFIG[APP_CONFIG['HOST_TYPE']]["Mailer_User"],
  :password             =>  APP_CONFIG[APP_CONFIG['HOST_TYPE']]["Mailer_PWD"],
  :authentication       => "plain",
  :enable_starttls_auto => APP_CONFIG[APP_CONFIG['HOST_TYPE']]["Mailer_Auto_SSL"]
}
ActionMailer::Base.default_url_options[:host] =  APP_CONFIG[APP_CONFIG['HOST_TYPE']]["Mailer_Host"] 
Mail.register_interceptor(DevelopmentMailInterceptor) if APP_CONFIG['HOST_TYPE']=='local' 