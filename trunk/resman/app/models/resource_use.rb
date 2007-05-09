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
    @collisions = @collisions | (all_collisions :before)
  end

  def changed_event_attributes
    
  end
  

  def before_save
    if @no_collision_check
      print "@no_collision_check"
      return
    end
    release_old_collisions if not new_record?
    check_for_new_collisions
  end

  def release_old_collisions
    puts "Checking for collisions in release_old_collisions ..."
    count = collision_count :before
    puts  "... found  #{count} events in collision validation"
    if count > 0
      puts  "We have a collision"
      self.collision=true
      case @@collision_policy
        when :democratic
          puts "Mark a collision ..."
          fc = first_collision_ru :after
          puts fc.inspect
          fc.collision= true
          print "saving ru ..."
          fc.save_without_collision_check
          puts "saved"
          collision = true
        when :no_collisions
          errors.add_to_base("Collission!")
          puts "save aborted!!!"
          return false
      end
    end
  end

  def check_for_new_collisions
    puts "Checking for collisions in check_for_new_collisions ..."
    count = collision_count :after
    puts  "... found  #{count} events in collision validation"
    if count > 0
      puts  "We have a collision"
      self.collision=true
      case @@collision_policy
        when :democratic
          puts "Mark a collision ..."
          fc = first_collision_ru :after
          puts fc.inspect
          fc.collision= true
          print "saving ru ..."
          fc.save_without_collision_check
          puts "saved"
          collision = true
        when :no_collisions
          errors.add_to_base("Collission!")
          puts "save aborted!!!"
          return false
      end
    else
      self.collision = false
      true
    end
  end

  def before_destroy
    puts "destroying ......"
    if @no_collision_check
      puts "No collision-check"
      return
    end
    logger.debug "Checking for collissions before destroy ..."
    count = collision_count :before
    logger.debug  "... found  #{count} events in collision validation"
    if count == 1 # me and another one
      logger.debug  "We have a collision to reduce"
      fc = first_collision_ru
      puts fc.inspect
      fc.collision= false
      print "saving ru ..."
      fc.save_without_collision_check
      puts "saved"
      collision = true
    end
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
    "events.date = '#{timepoint == :before ? self.event.date : self.event.date_new}' " +
    "and events.from < '#{timepoint == :before ? self.event.from.strftime("%H:%M:%S") : self.event.from_new.strftime("%H:%M:%S") }' "+
    "and events.to > '#{timepoint == :before ? self.event.to.strftime("%H:%M:%S") : self.event.to_new.strftime("%H:%M:%S") }' " +
    "and resource_uses.resource_id = #{ self.resource_id} " +
    (new_record? ? "": "and resource_uses.id != #{self.id.to_s}")
  end


  
end
