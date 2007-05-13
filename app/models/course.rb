class Course < ActiveRecord::Base
  has_many :event, :as => :schedulable
  has_many :eventseries, :as => :schedulable
end
