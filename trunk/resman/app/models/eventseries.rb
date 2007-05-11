class Eventseries < ActiveRecord::Base
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
      @eventlist << Event.new( :date => date, :from => self.start_time, :to => self.end_time)
      date += (7 * (self.weekly_each - 1)) if last_event_on_week? date, week_schema
      counter -= 1
    end
  end

  def create_daily
    date = self.start_date # easier than making an own function like "first_event ..."
    counter = self.events_count
    counter = 0 if counter == nil
    while counter > 0 
      @eventlist << Event.new( :date => date, :from => self.start_time, :to => self.end_time)
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
