Rails.application.config.assets.precompile += %w( jquery-ui-timepicker-addon.js )
Rails.application.config.assets.precompile += %w( jquery.preimage.js )
Rails.application.config.assets.precompile += %w( image_upload.js )
Rails.application.config.assets.precompile += 
  %w(*.png *.jpg *.jpeg *.gif *.ico vendor/somefile.js vendor/somefile.css \
     vendor/bootstrap/*.js vendor/bootstrap/*.css \
     vendor/bootstrap/**/*.js vendor/bootstrap/**/*.css)
Rails.application.config.assets.precompile += %w( jquery-ui-sliderAccess.js )
Rails.application.config.assets.precompile += 
  %w( images/*.png images/*.jpg images/*.jpeg imagers/*.gif images/*.ico )