class Event < ActiveRecord::Base
  has_many :resource_uses, :dependent => :destroy
  has_many :resources, :through => :resource_uses, :source => :resource

  validates_presence_of :date
  validates_presence_of :from
  validates_presence_of :to

  validate :from_is_before_to

  #after_save :save_resource_uses

  # validation that this event takes some time
  def from_is_before_to
    (self.from <=> self.to) <= 1
  end

  def date=(value)
    logger.debug "date is set with value " + value.to_s
    resource_uses.each { |ru| ru.changing_event_attributes }
    @date_new = value.clone
    logger.debug "@date_new is nil " if @date_new == nil
    
    write_attribute(:date, value)
  end

  def date_new
    logger.debug "@date_new is nil " if @date_new == nil
    @date_new or self.date
  end
  
  def from=(value)
    
    @from_new = value.dup
    #resource_uses.each { |ru| ru.changing_event_attributes }
    write_attribute(:from, value)
  end

  def from_new
    @from_new or self.from
  end

  def to=(value)
    
    @to_new = value.dup
    #resource_uses.each { |ru| ru.changing_event_attributes }
    write_attribute(:to, value)
  end

  def to_new
    @to_new or self.to
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
    logger.debug "Someone is calling the ids ..."
    @tmp_resource_ids != nil or @tmp_resource_ids = []
    @tmp_resource_ids = @tmp_resource_ids | resource_uses.collect {|resource_use| resource_use.resource_id.to_s}
    logger.debug "tmp_ids is" + @tmp_resource_ids.inspect
    @tmp_resource_ids.collect {|id| id.to_i}
  end

  def collide_with? event
    self.date === event.date and self.to > event.from and self.from < event.to
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
    self.reload
    logger.debug "Entering event.save_resource_uses"
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
