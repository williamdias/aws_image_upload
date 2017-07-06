module AwsImageUpload
  module FormInput

    def aws_image_upload(method, opts = {})
      aws_presigned_post = AwsImageUpload::Aws.presigned_post
      locals = { form: self, name: method, value: @object.send(method), aws_presigned_post: aws_presigned_post }
      path = File.expand_path("../../../app/views/aws_image_upload", __FILE__)
      partial = File.join(path, (opts[:multiple] ? '_multiple_images' : '_single_image'))
      view = ActionView::Base.new(path).extend(FontAwesome::Rails::IconHelper)
      Haml::Engine.new(File.read("#{partial}.html.haml")).render(view, locals)
    end

  end
end