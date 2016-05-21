# encoding: utf-8
class GameInfofileUploader < CarrierWave::Uploader::Base
  before :cache, :save_original_filename
 # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog
  IMAGE_EXTENSIONS = %w(jpg jpeg gif png)
  DOCUMENT_EXTENSIONS = %w(exe pdf doc docm docx xls xlsx)
  def extension_white_list
    IMAGE_EXTENSIONS + DOCUMENT_EXTENSIONS
  end
  def save_original_filename(file)
    model.original_filename = file.original_filename if file.respond_to?(:original_filename)
  end
  # create a new "process_extensions" method.  It is like "process", except
  # it takes an array of extensions as the first parameter, and registers
  # a trampoline method which checks the extension before invocation
  def self.process_extensions(*args)
    extensions = args.shift
    args.each do |arg|
      if arg.is_a?(Hash)
        arg.each do |method, args|
          processors.push([:process_trampoline, [extensions, method, args]])
        end
      else
        processors.push([:process_trampoline, [extensions, arg, []]])
      end
    end
  end
 
  # our trampoline method which only performs processing if the extension matches
  def process_trampoline(extensions, method, args)
    extension = File.extname(original_filename).downcase
    extension = extension[1..-1] if extension[0,1] == '.'
    self.send(method, *args) if extensions.include?(extension)
  end
  
 
 
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end
    #include Sprockets::Helpers::RailsHelper
    #include Sprockets::Helpers::IsolatedHelper
    include Sprockets::Rails::Helper
  # Provide a default URL as a default if there hasn't been a file uploaded:
   def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
#ActionController::Base.helpers.asset_path("fallback/" + [thumb, "LTTF_logo.png"].compact.join('_'))
  #
 ActionController::Base.helpers.asset_path("fallback/tiny_lttf_logo.jpg")
  #
   end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :resize_to_fit => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end
  

end
