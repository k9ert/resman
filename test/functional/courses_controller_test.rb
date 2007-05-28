require File.dirname(__FILE__) + '/../test_helper'
require 'courses_controller'

# Re-raise errors caught by the controller.
class CoursesController; def rescue_action(e) raise e end; end

class CoursesControllerTest < Test::Unit::TestCase
  fixtures :courses

  def setup
    @controller = CoursesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = courses(:first).id
  end

  def test_index
    get :index
    assert_response :success
    assert_template 'list'
  end

  def test_list
    get :list

    assert_response :success
    assert_template 'list'

    assert_not_nil assigns(:courses)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:course)
    assert assigns(:course).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:course)
  end

  def test_create
    num_courses = Course.count

    post :create, :course => {}

    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_courses + 1, Course.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:course)
    assert assigns(:course).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => @first_id
  end

  def test_destroy
    assert_nothing_raised {
      Course.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Course.find(@first_id)
    }
  end


  # --------------- Events-Testing -------------------------
  fixtures :events
  def test_new_event
    get :new_event, :id => 1

    assert_response :success
    assert_template 'new_event'

    assert_not_nil assigns(:event)
  end

  def test_create_event
    num_events = Resman::Event.count

    post :create_event, :event => {"start_time(1i)"=>"2007", "date(1i)"=>"2007", "start_time(2i)"=>"5", "date(2i)"=>"5", "date(3i)"=>"16", "start_time(3i)"=>"16", "start_time(4i)"=>"00", "end_time(1i)"=>"2007", "start_time(5i)"=>"17", "end_time(2i)"=>"5", "end_time(3i)"=>"16", "end_time(4i)"=>"08", "end_time(5i)"=>"17", "schedulable_id" => "1", "schedulable_type" => "Course"}

    assert assigns["event"] != nil
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1

    assert_equal num_events + 1, Resman::Event.count
  end

  def test_edit_event
    get :edit_event, :id => @first_id

    assert_response :success
    assert_template 'edit_event'

    assert_not_nil assigns(:event)
    assert assigns(:event).valid?
  end

  def test_update_event
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'show'
  end

  def test_destroy_event
    assert_nothing_raised {
      Resman::Event.find(10)
    }
    post :destroy_event, :id => 10
    assert_response :redirect
    assert_redirected_to :action => 'show', :id => 1

    assert_raise(ActiveRecord::RecordNotFound) {
      Resman::Event.find(10)
    }
  end
end
