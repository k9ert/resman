class EventEventseries < ActiveRecord::Migration
  def self.up
    add_column :events, :eventseries_id, :integer
  end

  def self.down
    remove_column :events, :eventseries_id
  end
end
