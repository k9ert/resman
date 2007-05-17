
class CoursesController < ApplicationController
  include Resman
  layout "standard"
  
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

  def create_eventseries
    @eventseries = Resman::Eventseries.new(params[:eventseries])
    @course = Course.find(params[:schedulable_id])
    @eventseries.schedulable = @course
    if @eventseries.save
      flash[:notice] = 'Events were successfully updated.'
    end
    render :action => 'show', :id => params[:schedulable_id]
  end

  def destroy_eventseries
    Eventseries.find(params[:id]).destroy
    redirect_to :action => "show"
  end
  
  def destroy_event
    redirect_to :controller => "events", :action => "destroy", :id => params[:id]
  end

  def edit_event
    redirect_to :controller => "events", :action => "edit", :id => params[:id]
  end

  
  
end
