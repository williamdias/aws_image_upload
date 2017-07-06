require 'test_helper'

class FormInputTest < ActionDispatch::IntegrationTest

  def check_image_template(template)
    assert_select template, '.image' do |image|
      assert_nil image.attr('id')
      assert_select image, '.preview', ''
      assert_select image, '.error.file-too-large'
      assert_select image, '.error.upload-failed'
      assert_select image, '.progress'
      assert_select image, '.delete.hidden'
    end
  end

  test "should render correct template for aws_image_upload single when its value is nil" do
    get new_model_a_url
    assert_select '#image.aws_image_upload' do |aws_image_upload|
      assert_select aws_image_upload, 'input[type="file"].file'
      assert_select aws_image_upload, 'input[type="hidden"][name="model_a[image]"]'
      assert_select aws_image_upload, '.images', ''
      assert_select aws_image_upload, '.placeholder'
      assert_select aws_image_upload, '.placeholder.invisible', 0
      assert_select aws_image_upload, '.template' do |template|
        check_image_template(template)
      end
    end
  end

  test "should render correct template for aws_image_upload multiple when its value is nil" do
    get new_model_a_url
    assert_select '#images.aws_image_upload' do |aws_image_upload|
      assert_select aws_image_upload, 'input[type="file"][multiple="multiple"].file'
      assert_select aws_image_upload, 'input[type="hidden"][name="model_a[images][]"]', 1
      assert_select aws_image_upload, '.images', ''
      assert_select aws_image_upload, '.placeholder'
      assert_select aws_image_upload, '.template' do |template|
        check_image_template(template)
      end
    end
  end

  test "should render correct template for aws_image_upload single when its value is not nil" do
    model = ModelA.first
    get edit_model_a_url(model)
    assert_select '#image.aws_image_upload' do |aws_image_upload|
      assert_select aws_image_upload, 'input[type="file"].file'
      assert_select aws_image_upload, 'input[type="hidden"][name="model_a[image]"][value=?]', model.image
      assert_select aws_image_upload, '.placeholder.invisible'
      assert_select aws_image_upload, '.images .image' do |image|
        assert_match /[0-9a-zA-Z]{12}/, image.attr('id')
        assert_select image, '.delete.hidden', 0
        assert_select image, '.preview img' do |img|
          assert_equal img.attr('src').to_s, "/images/#{model.image}"
        end
      end
    end
  end

  test "should render correct template for aws_image_upload multiple when its value is not nil" do
    model = ModelA.first
    get edit_model_a_url(model)
    assert_select '#images.aws_image_upload' do |aws_image_upload|
      assert_select aws_image_upload, 'input[type="file"].file'
      assert_select aws_image_upload, '.placeholder'
      assert_select aws_image_upload, 'input[type="hidden"][name="model_a[images][]"]' do |inputs|
        inputs[1..-1].each_with_index do |input, index|
          assert_equal input.attr('value'), model.images[index]
        end
      end
      assert_select aws_image_upload, '.images .image' do |images|
        images.each_with_index do |image, index|
          assert_match /[0-9a-zA-Z]{12}/, image.attr('id')
          assert_select image, '.delete.hidden', 0
          assert_select image, '.preview img' do |img|
            assert_equal img.attr('src').to_s, "/images/#{model.images[index]}"
          end
        end
      end
    end
  end

end