require 'yaml'

railsroot=Rails.root.to_s
APP_CONFIG =YAML.load_file(railsroot+'/config/myappconfig.yml')[Rails.env]
