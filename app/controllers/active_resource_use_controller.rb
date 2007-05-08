class ActiveResourceUseController < ApplicationController
  layout "standard"
  active_scaffold :resource_use
  

  def before_create_save(record)
    
  end
end
