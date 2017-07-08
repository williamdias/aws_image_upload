module AwsImageUpload
  module Aws

    def self.initialize
      if config_parametes_set?
        credentials = ::Aws::Credentials.new(config(:access_id), config(:secret))
        client = ::Aws::S3::Client.new(region: config(:region), credentials: credentials)
        @@s3_bucket = ::Aws::S3::Resource.new(client: client).bucket(config(:bucket))
      end
    end

    def self.presigned_post
      @@s3_bucket.presigned_post(key_starts_with: 'cache/', success_action_status: '201', acl: 'public-read')
    end

    def self.move_object(key)
      object = @@s3_bucket.object(key)
      new_key = key.sub('cache', 'store')
      object.move_to({ bucket: @@s3_bucket.name, key: new_key }, { acl: 'public-read' })
      new_key
    end

    def self.delete_object(key)
      object = @@s3_bucket.object(key)
      object.delete
    end

    def self.get_location_parts(location)
      uri = URI(URI.unescape(location))
      [uri.scheme, uri.host, uri.path[1..-1]]
    end

    private

      def self.config_parametes_set?
        [:region, :access_id, :secret, :bucket].each do |key|
          raise LoadError, 'You must configure AwsImageUpload initializer first' if config(key).blank?
        end
      end

      def self.config(key)
        AwsImageUpload.config[key.to_sym] if AwsImageUpload.config
      end

  end
end