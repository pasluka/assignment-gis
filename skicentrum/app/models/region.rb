class Region < ActiveRecord::Base
  has_and_belongs_to_many :resort
end
