class Resource < ActiveRecord::Base
  has_many :resource_uses, :dependent => :destroy

  validates_presence_of :name
  validates_uniqueness_of :name
end
