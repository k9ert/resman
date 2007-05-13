class CreateEventseries < ActiveRecord::Migration
  def self.up
    create_table :eventseries do |t|
        t.column :schedulable_id, :integer
        t.column :schedulable_type, :string
        t.column :start_date, :date
        t.column :start_time, :time
        t.column :end_time, :time
        t.column :events_count, :integer
        t.column :end_date, :date
        t.column :gen_type, :string
        
        t.column :daily_each, :integer
        t.column :daily_kind_of_day, :string
        
        t.column :weekly_each, :integer
        t.column :weekly_mon, :boolean
        t.column :weekly_tue, :boolean
        t.column :weekly_wed, :boolean
        t.column :weekly_thu, :boolean
        t.column :weekly_fri, :boolean
        t.column :weekly_sat, :boolean
        t.column :weekly_sun, :boolean
    end
  end

  def self.down
    drop_table :eventseries
  end
end
