# Resman
module Resman
  module SchedulableController
    
    module ActMacro
      def acts_as_SchedulableController_for klass
	class_inheritable_reader :schedulable_class
	class_inheritable_writer :schedulable_class
	self.schedulable_class=klass
        self.send(:include, Resman::SchedulableController::InstanceMethods)				  
      end
    end
    module InstanceMethods
      def create_eventseries
	@eventseries = Resman::Eventseries.new(params[:eventseries])
	@eventseries.payload do |event|
	  event.event_payload = EventPayload.new
	  # just as an Exampl % 
	  event.event_payload.payload1=5
	  event.event_payload.payload2="test"
	end
	my_schedulable = schedulable_class.find(params[:schedulable_id])
	@eventseries.schedulable = my_schedulable
	if @eventseries.save
	  flash[:notice] = 'Eventseries and Events were successfully updated.'
	end
	redirect_to :action => 'show', :id => params[:schedulable_id]
      end
     
      def destroy_eventseries
	es = Resman::Eventseries.find(params[:id])
	es.destroy
	redirect_to :action => "show", :id => es.schedulable.id
      end
      
      def new_event
	my_schedulable = schedulable_class.find(params[:id])
	@event = Resman::Event.new
	@event.schedulable = my_schedulable
	render :template => "events/new_event"
      end
      
      def create_event
	@event = Resman::Event.new(params[:event])
	if @event.save
	  flash[:notice] = 'Event was successfully created.'
	  redirect_to :action => 'show', :id => @event.schedulable.id
	else
	  render :template => 'events/new_event'
	end
      end
	
      def edit_event
	@event = Resman::Event.find(params[:id])
	render :template => "events/edit_event"
      end
    
      def update_event
	@event = Resman::Event.find(params[:id])
	if @event.update_attributes(params[:event])
	  flash[:notice] = 'Event was successfully updated.'
	  redirect_to :action => 'show', :id => @event.schedulable.id
	else
	  puts "Update fails"
	  render :action => 'edit_event'
	end
      end
    
      def destroy_event
	event =  Resman::Event.find(params[:id]).destroy
	redirect_to :action => 'show', :id => event.schedulable.id
      end
    end
  end

  

  module Schedulable
    def acts_as_schedulable 
      has_many :events, :class_name => 'Resman::Event', :as => :schedulable, :dependent => :destroy
      has_many :eventseries, :class_name => 'Resman::Eventseries', :as => :schedulable, :dependent => :destroy
    end
  end

  module Allocatable
    def acts_as_allocatable
      has_one :resource, :class_name => 'Resman::Resource', :as => :allocatable
    end
  end
end