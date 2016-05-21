Lttfproject::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false
  config.eager_load =false
 # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify
  # Expands the lines which load the assets
  config.assets.debug = true
  config.action_mailer.default_url_options = { :host => 'www.twlttf.org' }
  # Tell Action Mailer not to deliver emails to the real world.
  # The :test delivery method accumulates sent emails in the
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.perform_deliveries = true
  config.i18n.available_locales = ['zh-TW']
  railsroot=Rails.root.to_s
  APP_CONFIG =YAML.load_file(railsroot+'/config/myappconfig.yml')[Rails.env]
  Time.zone = "Taipei"
  Rails::Rack::Logger.class_eval do
  # Override logging to spit out UTC time to easier find user reported errors
  # https://github.com/rails/rails/blob/v3.2.14/railties/lib/rails/rack/logger.rb#L38
  def started_request_message(request)
    'Started %s "%s" for %s at %s' % [
      request.request_method,
      request.filtered_path,
      request.ip,
      Time.now.in_time_zone ]
  end
end
end
