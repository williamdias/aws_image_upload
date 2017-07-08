require 'test_helper'

class AwsTest < ActiveSupport::TestCase

  def aws_image_upload_config
    {
      region: 'us-east-1',
      access_id: 'access_id',
      secret: 'secret',
      bucket: 'bucket'
    }
  end

  test "should raise an error if config does not have all required parameters" do
    [:region, :access_id, :secret, :bucket].each do |param|
      config_parameters = aws_image_upload_config
      config_parameters.delete(param)
      assert_raises(LoadError) do
        AwsImageUpload.config = config_parameters
        AwsImageUpload::Aws.initialize
      end
    end
  end

  test "should raise an error if config is nil" do
    assert_raises(LoadError) do
      AwsImageUpload.config = nil
      AwsImageUpload::Aws.initialize
    end
  end

  test "should return a presigned_post" do
    presigned_post = AwsImageUpload::Aws.presigned_post
    assert_equal presigned_post.url, 'https://bucket.s3.amazonaws.com'
    assert_equal '201', presigned_post.fields['success_action_status']
    assert_equal 'public-read', presigned_post.fields['acl']
    assert_equal 'starts-with', presigned_post.instance_variable_get('@conditions')[1][0]
    assert_equal '$key', presigned_post.instance_variable_get('@conditions')[1][1]
    assert_equal 'cache/', presigned_post.instance_variable_get('@conditions')[1][2]
  end

  test "should return uri parts from image location" do
    location = 'https://bucket.s3.amazonaws.com/cache%2F5084ef04-f3d2-4fbc-baec-b98b98b52d7f%2F07734a2d8c99.png'
    scheme, host, object_key = AwsImageUpload::Aws.get_location_parts(location)
    assert_equal 'https', scheme
    assert_equal 'bucket.s3.amazonaws.com', host
    assert_equal 'cache/5084ef04-f3d2-4fbc-baec-b98b98b52d7f/07734a2d8c99.png', object_key
  end

end


