require File.dirname(__FILE__) + '/../test_helper'

class ResourceUseTest < Test::Unit::TestCase
  fixtures :resource_uses

  # Replace this with your real tests.
  def test_collision_democratic
    ev1 = Resman::Event.find(7)
    ev1.alloc_resource 1
    ev1.save
    assert_equal 1, ev1.resource_uses.size
    assert ev1.resource_uses[0].collision == true
    ev2 = Resman::Event.find(4)
    assert ev2.resource_uses[0].collision
  end

  def test_collision_destroy
    ev1 = Resman::Event.find(7) 
    ev1.alloc_resource 1
    ev1.save
    ev1.destroy
    ev2 = Resman::Event.find(4)
    assert_false ev2.resource_uses[0].collision
  end

  def notest_collision_edit
    ev7 = Resman::Event.find(7)
    ev7.alloc_resource 1
    ev3 = Resman::Event.find(3)
    ev3.alloc_resource 1
    ev3.save
    ev4 = Resman::Event.find(4)
    ev4.alloc_resource 1
    ev7.save
    ev4.save
    [ev7,ev3,ev4].each {|ev| assert ev.resource_uses[0].collision}
    ev7.date = '2006-12-12'
    [ev7,ev3,ev4].each {|ev| assert ev.resource_uses[0].collision}
    ev7.save
    puts "in test_collision_edit saved ev7"
    puts
    puts
    puts "length of resource_uses is " + ev7.resource_uses.size.to_s
    assert_false ev7.resource_uses[0].collision
    assert_false ev3.resource_uses[0].collision
    assert_false ev4.resource_uses[0].collision
    #[ev7,ev3,ev4].each {|ev| assert_false ev.resource_uses[0].collision}
  end

  def test_collision_no_collission
    ResourceUse.collision_policy = :no_collisions
    ev1 = Resman::Event.find(7)
    ev1.alloc_resource 1
    #assert_false ev1.save!
    assert_equal 0, ev1.resource_uses.size
    ev2 = Resman::Event.find(4)
    assert_false ev2.resource_uses[0].collision
  end
end
