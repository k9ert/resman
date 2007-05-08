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
    @collisions = all_collisions
  end

  def changed_event_attributes
    
  end
  

  def before_save
    @collisions.each {|co| co.save} if @collisions != nil
    if @no_collision_check
      print "@no_collision_check"
      return
    end
    puts "Checking for collisions ..."
    count = collision_count
    puts  "... found  #{count} events in collision validation"
    if count > 0
      puts  "We have a collision"
      self.collision=true
      case @@collision_policy
	when :democratic
	  puts "Mark a collision ..."
	  fc = first_collision_ru
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

  def before_destroy
    puts "destroying ......"
    if @no_collision_check
      puts "No collision-check"
      return
    end
    logger.debug "Checking for collissions before destroy ..."
    count = collision_count
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

  def collision_count
    raise "could not get collision count without resource_id" if resource_id == nil
    Event.count(:all, :conditions => 
    	collision_condition, 
	:include => "resource_uses"
    )
  end

  def all_collisions
    ResourceUse.find(:all, :conditions => collision_condition,
	:include => "event")
  end
  
  def first_collision_ru
    ResourceUse.find(:first, :conditions => collision_condition,
	:include => "event")

  end

  def collision_condition
    "events.date = '#{self.event.date}' " + 
    "and events.from < '#{self.event.to.strftime("%H:%M:%S")}' "+
    "and events.to > '#{self.event.from.strftime("%H:%M:%S")}' " + 
    "and resource_uses.resource_id = #{self.resource_id} " +
    (new_record? ? "": "and resource_uses.id != #{self.id.to_s}")
  end


  
end
