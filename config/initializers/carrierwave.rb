# frozen_string_literal: true

if Rails.env.production?
  puts 'CarrierWave will use cloud storage.'

  Cloudinary.config do |config|
    config.url = ENV['CLOUDINARY_URL']
    config.cache_storage = :file
  end

  CarrierWave.configure do |config|
    config.cache_storage = :file
  end
else
  puts 'CarrierWave will use file storage.'

  Cloudinary.config do |config|
    config.cloud_name = 'TutorSchedulerTestCloudName'
  end

  CarrierWave.configure do |config|
    config.cache_only = true
    config.cache_storage = :file
    config.enable_processing = false
    config.cache_dir = Rails.root.join('tmp/storage/carrier_wave/cache')
    config.store_dir = Rails.root.join('tmp/storage/carrier_wave/store')
  end
end
