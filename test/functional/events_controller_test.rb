








require File.dirname(__FILE__) + '/../test_helper'
require 'events_controller'

# Re-raise errors caught by the controller.
class EventsController; def rescue_action(e) raise e end; end

class EventsControllerTest < Test::Unit::TestCase
  fixtures :events

  set_fixture_class :events => Resman::Event

  def setup
    @controller = EventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    @first_id = events(:first).id
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

    assert_not_nil assigns(:events)
  end

  def test_show
    get :show, :id => @first_id

    assert_response :success
    assert_template 'show'

    assert_not_nil assigns(:event)
    assert assigns(:event).valid?
  end

  def test_new
    get :new

    assert_response :success
    assert_template 'new'

    assert_not_nil assigns(:event)
  end

  def test_create
    num_events = Event.count

    post :create, :event => {"start_time(1i)"=>"2007", "date(1i)"=>"2007", "start_time(2i)"=>"5", "date(2i)"=>"5", "date(3i)"=>"16", "start_time(3i)"=>"16", "start_time(4i)"=>"00", "end_time(1i)"=>"2007", "start_time(5i)"=>"17", "end_time(2i)"=>"5", "end_time(3i)"=>"16", "end_time(4i)"=>"08", "end_time(5i)"=>"17"}

    assert assigns["event"] != nil
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_equal num_events + 1, Event.count
  end

  def test_edit
    get :edit, :id => @first_id

    assert_response :success
    assert_template 'edit'

    assert_not_nil assigns(:event)
    assert assigns(:event).valid?
  end

  def test_update
    post :update, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'
  end

  def test_destroy
    assert_nothing_raised {
      Event.find(@first_id)
    }

    post :destroy, :id => @first_id
    assert_response :redirect
    assert_redirected_to :action => 'list'

    assert_raise(ActiveRecord::RecordNotFound) {
      Event.find(@first_id)
    }
  end
end
