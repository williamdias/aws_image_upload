require 'test_helper'

class ActsAsUploadableTest < ActiveSupport::TestCase

  test "should include AwsImageUpload::ActsAsUploadable in ApplicationRecord" do
    assert_includes ApplicationRecord.included_modules, AwsImageUpload::ActsAsUploadable
  end

  test "should have before_save callback set in model if it acts as uploadable" do
    before_save_callbacks = ModelA._save_callbacks.select{ |c| c.kind == :before }.map(&:filter)
    assert_includes before_save_callbacks, :aws_image_upload_before_save
  end

  test "should have before_destroy callback set in model if it acts as uploadable" do
    before_save_callbacks = ModelA._destroy_callbacks.select{ |c| c.kind == :before }.map(&:filter)
    assert_includes before_save_callbacks, :aws_image_upload_before_destroy
  end

  test "should have correct list of aws_image_upload_fields if model acts_as_uploadable" do
    assert_includes ModelA.aws_image_upload_fields, :image
    assert_includes ModelA.aws_image_upload_fields, :images
  end

  test "should have no aws_image_upload_fields if model does not act as uploadable" do
    assert_nil ModelB.aws_image_upload_fields
  end

  test "asd" do
    ModelB.new
  end

  test "should call before_save callback if model acts as uploadable" do
    mock = MiniTest::Mock.new.expect(:call, nil, [])
    obj = ModelA.new(image: 'image.jpg', images: ['image1.jpg', 'image2.jpg'])
    obj.stub(:aws_image_upload_before_save, mock) do
      obj.save
    end
    mock.verify
  end

  test "should call before_destroy callback if model acts as uploadable" do
    mock = MiniTest::Mock.new.expect(:call, nil, [])
    obj = ModelA.first
    obj.stub(:aws_image_upload_before_destroy, mock) do
      obj.destroy
    end
    mock.verify
  end

  test "should call aws_image_upload_save_string and aws_image_upload_save_array" do
    mock_string = MiniTest::Mock.new.expect(:call, nil, [:image])
    mock_array = MiniTest::Mock.new.expect(:call, nil, [:images])
    obj = ModelA.new(image: 'image.jpg', images: ['image1.jpg', 'image2.jpg'])
    obj.stub(:aws_image_upload_save_string, mock_string) do
      obj.stub(:aws_image_upload_save_array, mock_array) do
        obj.save
      end
    end
    mock_string.verify
    mock_array.verify
  end

  test "should call aws_image_upload_destroy_string and aws_image_upload_destroy_array" do
    mock_string = MiniTest::Mock.new.expect(:call, nil, [:image])
    mock_array = MiniTest::Mock.new.expect(:call, nil, [:images])
    obj = ModelA.first
    obj.stub(:aws_image_upload_destroy_string, mock_string) do
      obj.stub(:aws_image_upload_destroy_array, mock_array) do
        obj.destroy
      end
    end
    mock_string.verify
    mock_array.verify
  end

  test "should call aws_image_upload_move_image and update the value for each image" do
    obj = ModelA.new(image: 'image.jpg', images: ['image1.jpg', 'image2.jpg'])
    obj.stub(:aws_image_upload_move_image, 'new_image.jpg') do
      obj.save
      assert_equal 'new_image.jpg', obj.image
      obj.images.each do |image|
        assert_equal 'new_image.jpg', image
      end
    end
  end

  test "should not call aws_image_upload_move_image if fields are empty" do
    obj = ModelA.new(image: '', images: [''])
    obj.save
    assert_nil obj.image
    assert_empty obj.images
  end

  test "should call aws_image_upload_delete_image only for images that have been removed" do
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, ['image.jpg'])
    mock.expect(:call, nil, ['image1.jpg'])
    obj = ModelA.first
    obj.attributes = { image: 'new_image.jpg', images: ['new_image.jpg', 'image2.jpg'] }
    obj.stub(:aws_image_upload_delete_image, mock) do
      obj.save
    end
    mock.verify
  end

  test "should call aws_image_upload_delete_image for all images" do
    mock = MiniTest::Mock.new
    mock.expect(:call, nil, ['image.jpg'])
    mock.expect(:call, nil, ['image1.jpg'])
    mock.expect(:call, nil, ['image2.jpg'])
    obj = ModelA.first
    obj.stub(:aws_image_upload_delete_image, mock) do
      obj.destroy
    end
    mock.verify
  end

  test "should move image to permanent location" do
    location = 'https://bucket.s3.amazonaws.com/cache%2F5084ef04-f3d2-4fbc-baec-b98b98b52d7f%2F07734a2d8c99.png'
    AwsImageUpload::Aws.stub(:move_object, 'store/5084ef04-f3d2-4fbc-baec-b98b98b52d7f/07734a2d8c99.png') do
      assert_equal 'https://bucket.s3.amazonaws.com/store/5084ef04-f3d2-4fbc-baec-b98b98b52d7f/07734a2d8c99.png', ModelA.new.send(:aws_image_upload_move_image, location)
    end
  end

  test "should not move image if it's already in permanent location" do
    location = 'https://bucket.s3.amazonaws.com/store%2F5084ef04-f3d2-4fbc-baec-b98b98b52d7f%2F07734a2d8c99.png'
    assert_equal 'https://bucket.s3.amazonaws.com/store/5084ef04-f3d2-4fbc-baec-b98b98b52d7f/07734a2d8c99.png', ModelA.new.send(:aws_image_upload_move_image, location)
  end

  test "should return original location and not move image if test_mode is true" do
    AwsImageUpload.config[:test_mode] = true
    location = 'https://bucket.s3.amazonaws.com/cache%2F5084ef04-f3d2-4fbc-baec-b98b98b52d7f%2F07734a2d8c99.png'
    assert_equal location, ModelA.new.send(:aws_image_upload_move_image, location)
    AwsImageUpload.config[:test_mode] = false
  end

  test "should delete image" do
    location = 'https://bucket.s3.amazonaws.com/store%2F5084ef04-f3d2-4fbc-baec-b98b98b52d7f%2F07734a2d8c99.png'
    AwsImageUpload::Aws.stub(:delete_object, true) do
      assert ModelA.new.send(:aws_image_upload_delete_image, location)
    end
  end

  test "should not delete image if it's in temporary location" do
    location = 'https://bucket.s3.amazonaws.com/cache%2F5084ef04-f3d2-4fbc-baec-b98b98b52d7f%2F07734a2d8c99.png'
    assert_nil ModelA.new.send(:aws_image_upload_delete_image, location)
  end

  test "should not delete image if test_mode is true" do
    AwsImageUpload.config[:test_mode] = true
    location = 'https://bucket.s3.amazonaws.com/store%2F5084ef04-f3d2-4fbc-baec-b98b98b52d7f%2F07734a2d8c99.png'
    assert_nil ModelA.new.send(:aws_image_upload_delete_image, location)
    AwsImageUpload.config[:test_mode] = false
  end

end

