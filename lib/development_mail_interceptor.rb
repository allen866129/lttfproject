class DevelopmentMailInterceptor
  def self.delivering_email(message)
    message.subject = "#{message.to} #{message.subject}"
    message.to = APP_CONFIG[APP_CONFIG['HOST_TYPE']]['Mailer_Interceptor_Account']
  end
end