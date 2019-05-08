cd ~/rails_apps/lttfproject
rvm --create --ruby-version ruby-1.9.3@my_gemset
RAILS_ENV=production script/delayed_job restart