class Sufia::AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::MiniMagick
  include CarrierWave::Compatibility::Paperclip

  process convert: 'png'

  version :medium do
    process resize_to_limit: [300, 300]
  end

  version :thumb do
    process resize_to_limit: [100, 100]
  end

  def default_url
    "/assets/missing_#{version_name}.png"
  end

  def extension_white_list
    %w(jpg jpeg png gif bmp tif tiff)
  end
end
