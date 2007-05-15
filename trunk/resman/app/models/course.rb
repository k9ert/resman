include Resman
class Course < ActiveRecord::Base
  has_many :event, :class_name => 'Resman::Event', :as => :schedulable
  has_many :eventseries, :class_name => 'Resman::Eventseries', :as => :schedulable
end
