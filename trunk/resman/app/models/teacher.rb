class Teacher < ActiveRecord::Base
  has_one :resource, :class_name => 'Resman::Resource', :as => :allocatable
end
