class Event < ActiveRecord::Base
  has_many :resource_uses, :dependent => :destroy
  has_many :resources, :through => :resource_uses, :source => :resource

  validates_presence_of :date
  validates_presence_of :from
  validates_presence_of :to

  validate :from_is_before_to

  after_save :save_resource_uses

  # validation that this event takes some time
  def from_is_before_to
    (self.from <=> self.to) <= 1
  end

  def date=(value)
    resource_uses.each { |ru| ru.changing_event_attributes }
    write_attribute(:date, value)
    resource_uses.each { |ru| ru.changed_event_attributes } 
  end
  
  def from=(value)
    resource_uses.each { |ru| ru.changing_event_attributes }
    write_attribute(:from, value)
    resource_uses.each { |ru| ru.changed_event_attributes } 
  end

  def to=(value)
    resource_uses.each { |ru| ru.changing_event_attributes }
    write_attribute(:to, value)
    resource_uses.each { |ru| ru.changed_event_attributes } 
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

  private

  # Callback saves the transient resourceUses in @tmp_resource_ids
  def save_resource_uses
    @tmp_resource_ids != nil or @tmp_resource_ids = []
    # remove resource_uses not in list
    resource_uses.each do |resource_use|
      if not @tmp_resource_ids.include? resource_use.resource_id.to_s
	resource_uses.delete(resource_use)
      end
    end
    # add resource_uses in list (if not already there)
    @tmp_resource_ids.each do |id|
      if not resource_uses.collect {|resource_use| resource_use.resource_id}.include? id.to_i
	resource_uses.create(:resource_id => id.to_i)
      end
    end
    @tmp_resource_ids = nil
  end
end
