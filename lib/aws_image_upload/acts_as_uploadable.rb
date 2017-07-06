module AwsImageUpload
  module ActsAsUploadable
    extend ActiveSupport::Concern

    included do
      class_attribute :aws_image_upload_fields
    end

    class_methods do
      def acts_as_uploadable(field)
        before_save :permanently_save_uploaded_images
        self.aws_image_upload_fields ||= []
        self.aws_image_upload_fields <<= field.to_sym
      end
    end

    def permanently_save_uploaded_images
      self.aws_image_upload_fields.each do |field|
        case send(field)
        when Array
          send(field).each { |image| save_image(image) }
        when String
          save_image(send(field))
        end
      end
    end

    def save_image(image)
      puts image
    end

  end
end