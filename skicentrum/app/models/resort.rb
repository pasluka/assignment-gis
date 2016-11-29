class Resort < ActiveRecord::Base
  has_and_belongs_to_many :regions
  has_many :snowfalls
  has_many :tickets
end
