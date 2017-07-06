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
    assert_match /cache\/[0-9a-zA-Z\-]+\/\$\{filename\}/, presigned_post.fields['key']
    assert_equal '201', presigned_post.fields['success_action_status']
    assert_equal 'public-read', presigned_post.fields['acl']
  end

end


