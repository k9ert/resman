require File.dirname(__FILE__) + '/../test_helper'

class EventseriesTest < Test::Unit::TestCase
  fixtures :eventseries

  # Replace this with your real tests.
  def test_week_schedule
    ws = WeekSchedule.new(true,false,true,false,false,true,false)
    assert_equal "Mon Wed Sat ", ws.to_s
  end
  def test_event_series_to_s
    es = Eventseries.find(1)
    assert_equal "Starting from 2007-07-07 each Mon Thu Fri 9 events",
    		es.to_s
  end
end
