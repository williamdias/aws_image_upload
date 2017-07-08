module AwsImageUpload
  module ActsAsUploadable
    extend ActiveSupport::Concern

    included do
      class_attribute :aws_image_upload_fields
      before_save :aws_image_upload_before_save
      before_destroy :aws_image_upload_before_destroy
    end

    class_methods do
      def acts_as_uploadable(field)
        self.aws_image_upload_fields ||= []
        self.aws_image_upload_fields <<= field.to_sym
      end
    end

    private

      def aws_image_upload_before_save
        self.aws_image_upload_fields.each do |field|
          case send(field)
          when String
            aws_image_upload_save_string(field)
          when Array
            aws_image_upload_save_array(field)
          end
        end
      end

      def aws_image_upload_before_destroy
        self.aws_image_upload_fields.each do |field|
          case send(field)
          when String
            aws_image_upload_destroy_string(field)
          when Array
            aws_image_upload_destroy_array(field)
          end
        end
      end

      def aws_image_upload_save_string(field)
        new_value = send(field)
        old_value = eval("#{field}_changed?") ? eval("#{field}_was") : nil
        aws_image_upload_delete_image(old_value) if old_value
        new_value = aws_image_upload_move_image(new_value)
        send("#{field}=", new_value)
      end

      def aws_image_upload_save_array(field)
        new_values = send(field)
        old_values = eval("#{field}_changed?") ? eval("#{field}_was") : []
        old_values.delete_if { |i| new_values.include?(i) }.each { |i| aws_image_upload_delete_image(i) }
        new_values.map!{ |i| aws_image_upload_move_image(i) }
        send("#{field}=", new_values)
      end

      def aws_image_upload_destroy_string(field)
        value = send(field)
        aws_image_upload_delete_image(value) if value
      end

      def aws_image_upload_destroy_array(field)
        values = send(field)
        values.each { |i| aws_image_upload_delete_image(i) }
      end

      def aws_image_upload_move_image(location)
        scheme, host, object_key = AwsImageUpload::Aws.get_location_parts(location)
        new_object_key = object_key.starts_with?('cache/') ? AwsImageUpload::Aws.move_object(object_key) : object_key
        "#{scheme}://#{host}/#{new_object_key}"
      end

      def aws_image_upload_delete_image(location)
        _, _, object_key = AwsImageUpload::Aws.get_location_parts(location)
        AwsImageUpload::Aws.delete_object(object_key) if object_key.starts_with?('store/')
      end

  end
end