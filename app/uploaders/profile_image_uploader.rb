# frozen_string_literal: true

class ProfileImageUploader < CarrierWave::Uploader::Base
  include Cloudinary::CarrierWave

  # Store size
  process resize_to_limit: [300, 300]

  version :standard do
    process resize_to_limit: [300, 300]
  end

  version :thumb do
    process resize_to_limit: [50, 50]
  end

  def extension_whitelist
    %w[jpg jpeg gif png]
  end
end
