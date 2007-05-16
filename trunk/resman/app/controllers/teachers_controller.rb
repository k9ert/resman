class TeachersController < ApplicationController
  layout "standard"
  
  def index
    list
    render :action => 'list'
  end

  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :destroy, :create, :update ],
         :redirect_to => { :action => :list }

  def list
    @teacher_pages, @teachers = paginate :teachers, :per_page => 10
  end

  def show
    @teacher = Teacher.find(params[:id])
    @resource = @teacher.resource
  end

  def new
    @teacher = Teacher.new
  end

  def create
    @teacher = Teacher.new(params[:teacher])
    if @teacher.save
      flash[:notice] = 'Teacher was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @teacher = Teacher.find(params[:id])
  end

  def update
    @teacher = Teacher.find(params[:id])
    if @teacher.update_attributes(params[:teacher])
      flash[:notice] = 'Teacher was successfully updated.'
      redirect_to :action => 'show', :id => @teacher
    else
      render :action => 'edit'
    end
  end

  def destroy
    Teacher.find(params[:id]).destroy
    redirect_to :action => 'list'
  end

  def update_resource
    @teacher = Teacher.find(params[:allocatable_id])
    if params[:publish_as_resource] != "1"
      @teacher.resource != nil and @teacher.resource.destroy
    elsif @teacher.resource == nil
      logger.debug "should get created !!!"
      logger.debug "params[:resource => :name] is " + (params[:resource]).to_s
      @teacher.resource = Resman::Resource.new(:name => params[:resource][:name])
      logger.debug "XXXXXXXXXXXXXXXresource is " + @teacher.resource.inspect
      logger.debug "saving ..."
      @teacher.resource.save
      logger.debug "... saved: " + @teacher.resource.new_record?.to_s
      @teacher.save
    else
      logger.debug "Already saved ... updating"
      @teacher.resource.name = params[:resource][:name]
      logger.debug "name updated ...saving"
      @teacher.resource.save
      logger.debug "saved!"
    end
    @resource = @teacher.resource
    redirect_to :action => 'show', :id => @teacher
  end
end
