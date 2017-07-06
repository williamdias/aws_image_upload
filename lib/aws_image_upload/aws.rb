module AwsImageUpload
  module Aws

    def self.initialize
      if config_parametes_set?
        credentials = ::Aws::Credentials.new(config(:access_id), config(:secret))
        client = ::Aws::S3::Client.new(region: config(:region), credentials: credentials)
        @@s3_bucket = ::Aws::S3::Resource.new(client: client).bucket(config(:bucket))
      end
    end

    def self.config_parametes_set?
      [:region, :access_id, :secret, :bucket].each do |key|
        raise LoadError, 'You must configure AwsImageUpload initializer first' if config(key).blank?
      end
    end

    def self.config(key)
      AwsImageUpload.config[key.to_sym] if AwsImageUpload.config
    end

    def self.presigned_post
      @@s3_bucket.presigned_post(key: "cache/#{SecureRandom.uuid}/${filename}", success_action_status: '201', acl: 'public-read')
    end

  end
end