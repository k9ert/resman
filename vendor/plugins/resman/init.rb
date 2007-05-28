require "resman"

class ActiveRecord::Base
  extend Resman::Schedulable
  extend Resman::Allocatable
end

class ActionController::Base
  extend Resman::SchedulableController::ActMacro
end
