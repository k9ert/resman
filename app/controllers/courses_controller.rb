
class CoursesController < ApplicationController
  layout "standard"

  # The Class for which this controller is responsible for
  @@schedulable_class = Course
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @course_pages, @courses = paginate :courses, :per_page => 10
  end

  def show
    @course = Course.find(params[:id])
  end

  def new
    @course = Course.new
  end

  def create
    @course = Course.new(params[:course])
    if @course.save
      flash[:notice] = 'Course was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update_attributes(params[:course])
      flash[:notice] = 'Course was successfully updated.'
      redirect_to :action => 'show', :id => @course
    else
      render :action => 'edit'
    end
  end

  def destroy
    Course.destroy(params[:id])
    redirect_to :action => 'list'
  end

  #-----------reman-Actions-------------------
  def create_eventseries
    @eventseries = Resman::Eventseries.new(params[:eventseries])
    my_schedulable = @@schedulable_class.find(params[:schedulable_id])
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
    my_schedulable = @@schedulable_class.find(params[:id])
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
