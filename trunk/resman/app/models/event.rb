class Event < ActiveRecord::Base
  has_many :resource_uses
  has_many :resources, :through => :resource_uses
  belongs_to :schedulable, :polymorphic => true

  validates_presence_of :date
  validates_presence_of :start_time
  validates_presence_of :end_time

  after_save :save_resource_uses

  def before_destroy
    puts "informing before destroy"
    resource_uses.each { |ru| ru.changing_event_attributes }
  end

  def after_destroy
    resource_uses.each { |ru| ru.destroy }
  end
    
  # validation that this event takes some time
  def validate
    self.start_time < self.end_time
  end

  def date=(value)
    resource_uses.each { |ru| ru.changing_event_attributes }
    write_attribute(:date, value)
  end

  def start_time=(value)
    resource_uses.each { |ru| ru.changing_event_attributes }
    write_attribute(:start_time, value)
  end

  def end_time=(value)
    resource_uses.each { |ru| ru.changing_event_attributes }
    write_attribute(:end_time, value)
  end



  # set a new list of ids for the used resources
  def resource_ids=(ids)
    if ids == nil
      @tmp_resource_ids = []
    else
      @tmp_resource_ids = ids
    end
    logger.debug "someone set resource_ids with" + (@tmp_resource_ids == nil ? "nil" : @tmp_resource_ids.inspect.to_s)
  end
  
  # Returns an array of the ids of the used Resources
  def resource_ids
    @tmp_resource_ids != nil or @tmp_resource_ids = []
    @tmp_resource_ids = @tmp_resource_ids | resource_uses.collect {|resource_use| resource_use.resource_id.to_s}
    logger.debug "tmp_ids is" + @tmp_resource_ids.inspect
    @tmp_resource_ids.collect {|id| id.to_i}
  end

  def collide_with? event
    self.date === event.date and self.end_time > event.start_time and self.start_time < event.end_time
  end

  # allocate an resource by id. This allocation is transient until save
  def alloc_resource resource_id
    @tmp_resource_ids != nil or resource_ids
    @tmp_resource_ids << resource_id.to_s
  end

  # deallocate an resource by id. This allocation is transient until save
  def free_resource resource_id
    @tmp_resource_ids != nil or resource_ids
    @tmp_resource_ids.delete resource_id.to_s
  end



  # Callback saves the transient resourceUses in @tmp_resource_ids
  def save_resource_uses
    logger.debug "Entering event.save_resource_uses"
    logger.debug "date is " + self.date.to_s
    @tmp_resource_ids != nil or @tmp_resource_ids = []
    # remove resource_uses not in list
    resource_uses.each do |resource_use|
      if not @tmp_resource_ids.include? resource_use.resource_id.to_s
        logger.info "Deleting resourceUse with id #{resource_use.id}"
        resource_uses.delete(resource_use)
      else
        resource_use.save
      end
    end
    # add resource_uses in list (if not already there)
    @tmp_resource_ids.each do |id|
      if not resource_uses.collect {|resource_use| resource_use.resource_id}.include? id.to_i
        ru=resource_uses.create(:resource_id => id.to_i)
        logger.info "Created resourceUse with id #{ru.id}"
      end
    end
    @tmp_resource_ids = nil
  end
end
