module Resman
  # a value-Object
  class WeekSchedule
    @@day_short_names_a = %w{ Mon Tue Wed Thu Fri Sat Sun}
    @@day_short_names_h = { :mon => 0, :tue => 1,  :wed => 2, :thu => 3, :fri => 4, :sat => 6, :sun => 7}
    @@empty_hash = { :mon => false, :tue => false,  :wed => false, :thu => false, :fri => false, :sat => false, :sun => false }
    
    def initialize (*args)
      @dayhash = @@empty_hash.dup
      if args[0].class == Hash
        args[0].each do |key,value|
          @dayhash[key] = value
        end
      elsif args[0].class == Array
        args[0].each_index do |i|
          @dayhash[@@day_short_names_a[i].downcase.to_sym] = args[i]
        end
      elsif args.size == 7 and args.class == Array
        args.each_index do |i|
          @dayhash[@@day_short_names_a[i].downcase.to_sym] = args[i]
        end
      elsif
        raise "wrong arguments in initialize"
      end
    end
    def method_missing symbol
      @dayhash.has_key?  symbol or raise "dont know this day" + symbol.to_s
      @dayhash[symbol]
    end
    
    # set the comercialweekday to the given boolean
    # Monday is 1, Sunday is 7
    #def set_wday wday, myboolean
    #   self.send((@@day_short_names[wday] + "=").downcase.to_sym,  myboolean)
    #end
  
    def to_s
      myarray = Array.new
      @@day_short_names_a.each_index do |i|
        myarray << @@day_short_names_a[i] if @dayhash[@@day_short_names_a[i].downcase.to_sym] == true
      end
      myarray.join(" ")
    end

    private
    
  end
  
  class Eventseries < ActiveRecord::Base
    has_many :events, :dependent => :destroy
    belongs_to :schedulable, :polymorphic => true
    #before_destroy {|es| es.events.each {|ev| ev.destroy}
    
    composed_of :weekschedule,
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
    #validates_presence_of :events_count, :if => Proc.new {|es| es.end_date == nil}
    #validates_presence_of :end_date, :if => Proc.new {|es| es.events_count == nil}
    validates_format_of :end_based_on, :with => /^eventcount|enddate$/
    validates_format_of :gen_type, :with => /^daily|weekly|monthly|yearly$/
  
    def validate
      self.weekly_each = 1 if self.weekly_each == nil
      self.daily_each = 1 if self.daily_each == nil
      if self.start_time >= self.end_time
        errors.add_to_base("start_time should be before end_time")
        return false
      end
      if self.end_based_on == "enddate"
        if self.start_date >= self.end_date
            errors.add_to_base("start_date should be before end_date")
            return false
        end
      elsif self.end_based_on == "events_count"
	if self.events_count==nil or self.events_count<=0
	  errors.add_to_base("How many events should get generated?")
	  return false
	end
      end
      generate
      if @eventlist.size == 0
        errors.add_to_base("At least one Event should get generated")
        return false
      end
      true
    end
    def before_save
      logger.debug "self.events_count is " + self.events_count.inspect
      generate
      self.events = @eventlist
    end

    def before_destroy
      logger.debug "Destroying all corresponding events ..."
      self.events.each {|ev| ev.destroy}
      logger.debug "...Done"
    end

    def Eventseries.create_weekly_until(start_date, end_date, start_time, end_time, weekschedule, resource_ids=[])
      Eventseries.new(:start_date => start_date,
                        :end_date   => end_date,
                        :start_time => start_time,
                        :end_time   => end_time,
                        :end_based_on => "enddate",
                        :gen_type    => "weekly",
                        :weekly_each=> 1,
                        :weekschedule => weekschedule,
                        :resource_ids => resource_ids)
    end
  


    def after_destroy
      
      puts "XXXXXXXXXXXXXXXXXXXXXXXXXXXXafterDestroyXXXXXXXXXXXXXXX"
      logger.debug "after detroy is called!"
    end

    def resource_ids
      @resource_ids ||= []
    end

    def resource_ids=(value)
      @resource_ids = value
    end

    def payload(&action)
      @payload_action = action
    end

    def to_s
      me_as_string = ""
      me_as_string = "Starting from "+start_date.to_s+" "
      case self.gen_type
	when "daily"
	  me_as_string += "daily #{self.daily_kind_of_day == 'workday' ? ' (only workdays) ' : '(weekend as well) '}"
	  me_as_string += "#{self.events_count} days long."
	when "weekly"
	  me_as_string += "each #{self.weekschedule.to_s} #{self.events_count} events"
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
      week_schema = [ false, self.weekschedule.mon, self.weekschedule.tue, self.weekschedule.wed, self.weekschedule.thu, self.weekschedule.fri, self.weekschedule.sat, self.weekschedule.sun]
      date = self.start_date - 1 # easier than making an own function like "first_event ..."
      counter = self.events_count
      while true
	date = next_event_date week_schema, date
	logger.debug "self.events_count is " + self.events_count.inspect
	if self.end_based_on == "eventcount"
	  break if counter == 0
	elsif self.end_based_on == "enddate"
	  break if date > self.end_date
	end
	@eventlist << new_event(date)
	date += (7 * (self.weekly_each - 1)) if last_event_on_week? date, week_schema
	counter -= 1
      end
    end
  
    def create_daily
      date = self.start_date # easier than making an own function like "first_event ..."
      counter = self.events_count
      counter = 0 if counter == nil
      while counter > 0 
	@eventlist << new_event(date)
	counter -=1
	if self.end_based_on == "eventcount"
	  break if counter == 0
	elsif self.end_based_on == "enddate"
	  break if date > self.end_date
	end
	date += self.daily_each
	date += self.daily_each while self.daily_kind_of_day == "workday" and (is_workday? date) 
	counter -= 1
      end
    end
  
    def next_event_date week_schema, date
      date += 1 # We want the NEXT date
      
      logger.debug "and week_schema of " + week_schema.inspect
      (date.cwday..14).each do |i|
	return date if week_schema[i > 7 ? i-7 : i]
	date += 1
      end
      raise "should not happend. date is #{date.to_s} \nweek_schema is #{week_schema.inspect}"
    end
  
    def last_event_on_week? date, week_schema
      (date.cwday..7).to_a.reverse.each do |i|
	next if not week_schema[i]
	return date.cwday == i
      end
      raise "day is not in week_schema"
    end
  
    def is_workday? date
      false if date.cwday == 7 or date.cwday == 6
    end

    def new_event(date)
      Event.new(:date => date, 
      		:start_time => self.start_time,
		:end_time => self.end_time, 
		:eventseries_id => self.id, 
		:schedulable => self.schedulable,
		:resource_ids => self.resource_ids) do |event|
      if @payload_action != nil
        @payload_action.call(event)
      end
		end
      
    end
  
  end
end


