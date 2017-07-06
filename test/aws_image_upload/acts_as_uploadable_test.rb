require 'test_helper'

class ActsAsUploadableTest < ActiveSupport::TestCase

  test "should include AwsImageUpload::ActsAsUploadable in ApplicationRecord" do
    assert_includes ApplicationRecord.included_modules, AwsImageUpload::ActsAsUploadable
  end

  test "should have before_save callback set in model acts as uploadable" do
    before_save_callbacks = ModelA._save_callbacks.select{ |c| c.kind == :before }.map(&:filter)
    assert_includes before_save_callbacks, :permanently_save_uploaded_images
  end

  test "should not have before_save callback set in model does not act as uploadable" do
    before_save_callbacks = ModelB._save_callbacks.select{ |c| c.kind == :before }.map(&:filter)
    assert_not_includes before_save_callbacks, :permanently_save_uploaded_images
  end

  test "should have correct list of aws_image_upload_fields if model acts_as_uploadable" do
    assert_includes ModelA.aws_image_upload_fields, :image
    assert_includes ModelA.aws_image_upload_fields, :images
  end

  test "should have no aws_image_upload_fields if model does not act as uploadable" do
    assert_nil ModelB.aws_image_upload_fields
  end

  test "should call permanently_save_uploaded_images method before save if model acts as uploadable" do
    mock = MiniTest::Mock.new.expect(:call, nil, [])
    obj = ModelA.new(image: 'image.jpg', images: ['image1.jpg', 'image2.jpg'])
    obj.stub(:permanently_save_uploaded_images, mock) do
      obj.save
    end
    mock.verify
  end

end


