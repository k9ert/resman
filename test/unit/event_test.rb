require File.dirname(__FILE__) + '/../test_helper'

include Resman
class EventTest < Test::Unit::TestCase
  fixtures :events

  def test_collide
    ev1 = Resman::Event.find(1)
    ev2 = Resman::Event.find(2)
    ev3 = Resman::Event.find(3)
    ev4 = Resman::Event.find(4)
    ev5 = Resman::Event.find(5)
    ev6 = Resman::Event.find(6)
    ev7 = Resman::Event.find(7)
    ev8 = Resman::Event.find(8)
    ev9 = Resman::Event.find(9)
    
    assert ev1.collide_with?(ev1)
    assert_false ev1.collide_with?(ev2)
    assert ev1.collide_with?(ev3)
    assert ev1.collide_with?(ev4)
    assert ev1.collide_with?(ev5)
    assert_false ev1.collide_with?(ev6)
    assert ev1.collide_with?(ev7)
    assert_false ev1.collide_with?(ev8)
    assert_false ev1.collide_with?(ev9)
  end

  def test_alloc_resource
    #logger.info "XXXXXXXXXXXXXXXXX test_alloc_resource XXXXXXXXXXXXXXXXXX"
    ev1 = Resman::Event.find(1)
    ev1.alloc_resource 1
    ev1.save
    assert_equal(1,ev1.resource_uses.length)
    #logger.info "XXXXXXXXXXXXXXXXX test_alloc_resource (ENDE) XXXXXXXXXXXXXXXXXX"
  end

  def test_free_resource
    ev1 = Resman::Event.find(1)
    ev1.free_resource 1
    ev1.save
  end

  def test_free_resource
    ev1 = Resman::Event.find(1)
    puts "\n1:length is : " + ev1.resources.size.to_s
    ev1.alloc_resource 1
    puts "\n2:length is : " + ev1.resources.size.to_s
    ev1.save
    puts "in test_free_resource event saved"
    assert_equal(1,ev1.resource_uses.length)
    length = ev1.resource_uses.length
    ev1.free_resource 1
    ev1.save
    puts "in test_free_resource event saved"
    assert_equal(length-1,ev1.resource_uses.length)
  end

  def test_event_destroy
    ev1 = Resman::Event.find(1)
    ev1.alloc_resource 1
    ev1.save
    puts "in test_event_destroy event saved"
    assert_equal(1,ev1.resource_uses.size)
    ev1_id = ResourceUse.find(:first, :conditions => "resource_id = " +ev1.id.to_s)
    puts "In test_event_destroy now I call destroy "
    ev1.destroy
    assert_raise(ActiveRecord::RecordNotFound) { ResourceUse.find(ev1_id) }
  end
  
end
