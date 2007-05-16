require File.dirname(__FILE__) + '/../test_helper'

class EventseriesTest < Test::Unit::TestCase
  fixtures :eventseries

  # Replace this with your real tests.
  def test_week_schedule1
    ws = Resman::WeekSchedule.new(true,false,true,false,false,true,false)
    assert_equal "Mon Wed Sat", ws.to_s
  end

  def test_week_schedule2
     ws = Resman::WeekSchedule.new(*[false,true,true,false,false,true,false])
     assert_equal "Tue Wed Sat", ws.to_s
  end

  def test_week_schedule3
     ws = Resman::WeekSchedule.new([false,true,true,false,false,true,false])
     assert_equal "Tue Wed Sat", ws.to_s
  end

  def test_week_schedule4
     ws = Resman::WeekSchedule.new(:mon => false, :tue => true, :wed => true, 
                           :thu => false, :fri => false,:sat => true)
     assert_equal "Tue Wed Sat", ws.to_s
  end
  

  


  def test_event_series_to_s
    es = Resman::Eventseries.find(1)
    assert_equal("Starting from 2007-07-07 each Mon Thu Fri 9 events", es.to_s)
  end


end
