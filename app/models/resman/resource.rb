module Resman
  class Resource < ActiveRecord::Base
    has_many :resource_uses, :dependent => :destroy
    has_many :events, :through => :resource_uses 
    belongs_to :allocatable, :polymorphic => true
  
    validates_presence_of :name
    validates_uniqueness_of :name
  end
end

