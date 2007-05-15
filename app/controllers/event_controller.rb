class EventController < ApplicationController
  layout "standard"
  
  def index
    redirect_to :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @event_pages, @events = paginate :events, :per_page => 10
    init_eventseries
  end

  def show
    @event = Event.find(params[:id])
    init_eventseries
  end

  def new
    @event = Event.new
    init_eventseries
  end

  def create
    @event = Event.new(params[:event])
    if @event.save
      flash[:notice] = 'Event was successfully created.'
      redirect_to :action => 'list'
    else
      logger.debug "Create fails, Errors following"
      @event.errors.each_full { |msg| logger.debug msg }
      render :action => 'new'
    end
    init_eventseries
  end

  def edit
    @event = Event.find(params[:id])
    init_eventseries
  end

  def update
    @event = Event.find(params[:id])
    if @event.update_attributes(params[:event])
      flash[:notice] = 'Event was successfully updated.'
      redirect_to :action => 'list'
    else
      puts "Update fails"
      render :action => 'edit'
    end
    init_eventseries
  end

  def destroy
    Event.find(params[:id]).destroy
    init_eventseries
    redirect_to :action => 'list'
  end

  def create_eventseries
    init_eventseries
    if @eventseries.save
      flash[:notice] = 'Event was successfully updated.'
      redirect_to :action => 'list'
    else
      @event_pages, @events = paginate :events, :per_page => 10
      render :action => 'list'
    end
  end

  private

  def init_eventseries
    @eventseries = Eventseries.new(params[:eventseries])
  end
end
