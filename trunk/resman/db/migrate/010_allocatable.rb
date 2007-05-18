class Allocatable < ActiveRecord::Migration
  def self.up
    add_column :resources, :allocatable_id, :integer
    add_column :resources, :allocatable_type, :string
  end

  def self.down
    remove_column :resources, :allocatable_id, :integer
    remove_column :resources, :allocatable_type, :string
  end
end
