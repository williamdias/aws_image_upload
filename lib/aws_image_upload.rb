require 'aws_image_upload/railtie' if defined? Rails

module AwsImageUpload
  mattr_accessor :config
end

