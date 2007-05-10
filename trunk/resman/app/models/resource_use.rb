class ResourceUse < ActiveRecord::Base
  
  belongs_to :event
  belongs_to :resource

  validates_presence_of :event_id, :message => "event_id darf nicht leer sein"
  validates_presence_of :resource_id, :message => "resource_id darf nicht leer sein"

   @@collision_policy = :democratic
  # or :no_collisions
  def ResourceUse.collision_policy=(sym)
    if sym != :democratic and sym != :no_collisions
      raise "unknown collision_policy" 
    end
    @@collision_policy = sym
  end

  def save_without_collision_check
    @no_collision_check = true
    save
    @no_collision_check = false
  end

  # callback to remember all collisions
  def changing_event_attributes
    @my_date = event.date.clone
    logger.debug "event will change, mydate is " + (@my_date ==  nil ? "(nil)" : @my_date.to_s)
  end

  def changed_event_attributes
    
  end
  

  def before_save
    logger.debug "ENTERING before_save of resource_use"
    if @no_collision_check
      print "@no_collision_check"
      logger.debug "LEAVING before_save of resource_use"
      return
    end
    logger.debug "in before_save of resource_use"
    logger.debug "mydate is " + @my_date.to_s + "so ..."
    if not new_record? and @my_date
      release_old_collisions
    end
    check_for_new_collisions
    logger.debug "LEAVING before_save of resource_use"
  end

  def release_old_collisions
    logger.debug "ENTERING release_old_collisions ...(resource_use.id = #{self.id})"
    count = collision_count :before
    logger.debug  "... found  #{count} events in collision validation"
    if count > 0
      # Collision could be outdated for all of them
      logger.debug ">>>>>>>>>>>>>>>>>>>>>>>>Inform them to check for their Collisions ...."
      all_collisions(:before).each {|ru| ru.save }
      logger.debug "<<<<<<<<<<<<<<<<<<<<<<<<... Informed!!!!"
    end
    logger.debug "LEAVING release_old_collisions ...(resource_use.id = #{self.id})"
  end

  def check_for_new_collisions
    logger.debug "ENTERING check_for_new_collisions ...(resource_use.id = #{self.id})"
    count = collision_count :after
    logger.debug  "... found  #{count} events in collision validation"
    if count > 0
      logger.debug  "We have a collision"
      self.collision=true
      case @@collision_policy
        when :democratic
          logger.debug "Mark a collision ..."
          mark_collision all_collisions :after
          self.collision = true
        when :no_collisions
          errors.add_to_base("Collission!")
          logger.debug "save aborted!!!"
          return false
      end
    else
      logger.debug "Setting collision to false"
      self.collision = false
      true
    end
    logger.debug "LEAVING check_for_new_collisions ...(resource_use.id = #{self.id})"
  end

  def mark_collision resource_uses
    resource_uses = [resource_uses] if resource_uses.class != Array
    resource_uses.each do |resource_use|
      resource_use.collision = true
      resource_use.save_without_collision_check
    end
  end

  def unmark_collision resource_uses
    resource_uses.each do |resource_use|
      resource_use.collision = false
      resource_use.save_without_collision_check
    end
  end

  def after_destroy
    puts "destroying ......"
    if @no_collision_check
      puts "No collision-check"
      return true
    end
    release_old_collisions
  end

  def collision_count timepoint
    raise "could not get collision count without resource_id" if resource_id == nil
    Event.count(:all, :conditions => 
    	(collision_condition timepoint), 
	:include => "resource_uses"
    )
  end

  def all_collisions timepoint
    ResourceUse.find(:all, :conditions => (collision_condition timepoint),
	:include => "event")
  end
  
  def first_collision_ru timepoint
    ResourceUse.find(:first, :conditions => (collision_condition timepoint),
	:include => "event")

  end

  def collision_condition timepoint
    timepoint == :before or timepoint == :after or raise "unexpected timepoint"
    logger.debug "COLLISION_CONDITION with timepoint " + timepoint.id2name
    logger.debug "event.date is: " +self.event.date.to_s if timepoint == :after
    logger.debug "@mydate is " + @mydate.to_s + " ... reloading" if timepoint == :before
    # Don't know, why, but it#s necessary
    event.reload if timepoint == :after
    logger.debug "@mydate is " + @mydate.to_s if timepoint == :before
    "events.date = '#{timepoint == :before ? @my_date : self.event.date}' " +
    "and events.from < '#{timepoint == :before ? self.event.to.strftime("%H:%M:%S") : self.event.to.strftime("%H:%M:%S") }' "+
    "and events.to > '#{timepoint == :before ? self.event.from.strftime("%H:%M:%S") : self.event.from.strftime("%H:%M:%S") }' " +
    "and resource_uses.resource_id = #{ self.resource_id} " +
    (new_record? ? "": "and resource_uses.id != #{self.id.to_s}")
  end


  
end
