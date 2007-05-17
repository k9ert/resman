include Resman
class Course < ActiveRecord::Base
  has_many :events, :class_name => 'Resman::Event', :as => :schedulable, :dependent => :destroy
  has_many :eventseries, :class_name => 'Resman::Eventseries', :as => :schedulable, :dependent => :destroy
end
