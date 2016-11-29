class RegionsResort < ActiveRecord::Base
  belongs_to :resort
  belongs_to :region
end
