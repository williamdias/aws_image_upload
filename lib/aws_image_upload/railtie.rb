require 'haml'
require 'aws-sdk'
require 'font-awesome-rails'
require 'jquery-fileupload-rails'

require 'aws_image_upload/aws'
require 'aws_image_upload/acts_as_uploadable'
require 'aws_image_upload/form_input'

module AwsImageUpload
  class Railtie < Rails::Railtie

    config.assets.paths << File.expand_path("../../../app/assets/javascripts", __FILE__)
    config.assets.paths << File.expand_path("../../../app/assets/stylesheets", __FILE__)

    initializer 'aws_image_upload.active_record' do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.include AwsImageUpload::ActsAsUploadable
      end
    end

    initializer 'aws_image_upload.action_view' do
      ActiveSupport.on_load(:action_view) do
        ActionView::Helpers::FormBuilder.include AwsImageUpload::FormInput
      end
    end

    initializer 'aws_image_upload.aws' do
      config.after_initialize do
        AwsImageUpload::Aws.initialize
      end
    end

  end
end
