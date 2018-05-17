$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "aws_image_upload/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "aws_image_upload"
  s.version     = AwsImageUpload::VERSION
  s.authors     = ["William Dias"]
  s.email       = ["william.dias@gmail.com"]
  s.homepage    = "http://www.fottorama.com.br"
  s.summary     = "Summary of AwsImageUpload."
  s.description = "Description of AwsImageUpload."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency 'rails', '~> 5.1.6'
  s.add_dependency 'jquery-fileupload-rails', '~> 0.4.7'
  s.add_dependency 'font-awesome-rails', '~> 4.7.0'
  s.add_dependency 'aws-sdk', '~> 2.10.1'
  s.add_dependency 'haml', '~> 4.0.7'

  s.add_dependency 'jquery-rails'
  s.add_dependency 'sass-rails', '~> 5.0'
  s.add_dependency 'coffee-rails', '~> 4.2'

  s.add_development_dependency 'sqlite3'
end
