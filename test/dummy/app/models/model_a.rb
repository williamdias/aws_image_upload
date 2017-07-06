class ModelA < ApplicationRecord
  serialize :images, Array

  acts_as_uploadable :image
  acts_as_uploadable :images
end
