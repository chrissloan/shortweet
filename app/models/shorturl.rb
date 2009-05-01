class Shorturl < ActiveRecord::Base
  validates_uniqueness_of   :target_url
end
