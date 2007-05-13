# a value-Object
class WeekSchedule
  attr_reader :mon, :tue, :wed, :thu, :fri, :sat, :sun
  @@day_short_names = %w{ Mon Thu Wed Thu Fri Sat Sun}
  def initialize (mon,tue,wed,thu,fri,sat,sun)
    @mon = mon,
    @tue = tue,
    @wed = wed,
    @thu = thu,
    @fri = fri,
    @sat = sat,
    @sun = sun
  end

  def to_s
    mystring = ""
    myarray = [@mon, @tue, @wed, @thu, @fri, @sat, @sun]
    myarray.each_index do |index|
      myarray[index] and mystring += @@day_short_names[index] + " "
    end
    mystring
  end
end

class Eventseries < ActiveRecord::Base
  belongs_to :schedulable, :polymorphic => true
  
  composed_of 	:weekschedule,
  		:class_name => WeekSchedule,
		:mapping =>
		  [   # database	ruby
		    [ :weekly_mon,	:mon ],
		    [ :weekly_tue,	:tue ],
		    [ :weekly_wed,	:wed ],
		    [ :weekly_thu,	:thu ],
		    [ :weekly_fri,	:fri ],
		    [ :weekly_sat,	:sat ],
		    [ :weekly_sun,	:sun ]
		  ]
  
  
  validates_presence_of :start_date
  validates_presence_of :events_count, :if => Proc.new {|es| es.end_date == nil}
  validates_presence_of :end_date, :if => Proc.new {|es| es.events_count == nil}

  def validate
    if self.start_time >= self.end_time
      errors.add_to_base("start_time should be after end_time")
      return false
    end
    generate
    if @eventlist.size == 0
      errors.add_to_base("At least one Event should get generated")
      return false
    end
    true
  end

  def after_save
    generate
    @eventlist.each {|event| event.save}
  end

  def to_s
    me_as_string = ""
    me_as_string = "Starting from "+start_date.to_s+" "
    case self.gen_type
      when "daily"
	me_as_string += "daily #{self.daily_kind_of_day == 'workday' ? ' (only workdays) ' : '(weekend as well) '}"
	me_as_string += "#{self.events_count} days long."
      when "weekly"
	me_as_string += "each #{self.weekschedule.to_s}#{self.events_count} events"
    end
  end

  private
  
  def generate
    @eventlist = Array.new
    case self.gen_type
      when "daily"
        create_daily
      when "weekly"
        create_weekly
      when "monthly"
        create_monthly
      when "yearly"
        create_yearly
      else
        raise "unknown gen_type"
    end
  end

  def create_weekly
    week_schema = [ false, self.weekly_mon, self.weekly_tue, self.weekly_wed, self.weekly_thu, self.weekly_fri, self.weekly_sat, self.weekly_sun]
    logger.debug week_schema.inspect
    date = self.start_date - 1 # easier than making an own function like "first_event ..."
    counter = self.events_count
    while true
      date = next_event_date week_schema, date
      break if counter == 0 or date > self.end_date
      @eventlist << Event.new( :date => date, :start_time => self.start_time, :end_time => self.end_time)
      date += (7 * (self.weekly_each - 1)) if last_event_on_week? date, week_schema
      counter -= 1
    end
  end

  def create_daily
    date = self.start_date # easier than making an own function like "first_event ..."
    counter = self.events_count
    counter = 0 if counter == nil
    while counter > 0 
      @eventlist << Event.new( :date => date, :start_time => self.start_time, :end_time => self.end_time)
      counter -=1
      break if counter == 0 or date > self.end_date
      date += self.daily_each
      date += self.daily_each while self.daily_kind_of_day == "workday" and (is_workday? date) 
      counter -= 1
    end
  end

  def next_event_date week_schema, date
    logger.debug "try to find next date for " + date.to_s
    date += 1 # We want the NEXT date
    
    logger.debug "and week_schema of " + week_schema.inspect
    (date.cwday..13).each do |i|
      return date if week_schema[i > 7 ? i-7 : i]
      date += 1
    end
    raise "should not happend"
  end

  def last_event_on_week? date, week_schema
    logger.debug "In last_event_on_week value date is " + date.to_s
    logger.debug "this date is day " + date.cwday.to_s + " of week"
    (date.cwday..7).to_a.reverse.each do |i|
      next if not week_schema[i]
      return date.cwday == i
    end
    raise "day is not in week_schema"
  end

  def is_workday? date
    false if date.cwday == 7 or date.cwday == 6
  end
  
end


