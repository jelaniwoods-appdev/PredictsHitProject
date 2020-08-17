Cloudinary.config do |config|
  config.cloud_name = ENV["CLOUDINARY_CLOUD_NAME"]
  config.api_key = ENV["CLOUDINARY_API_KEY"]
  config.api_secret = ENV["CLOUDINARY_API_SECRET"]
  config.cdn_subdomain = true
end

CarrierWave.configure do |config|
 config.cache_storage = :file
 # disable processing for development purposes
 #config.enable_processing = false
end
