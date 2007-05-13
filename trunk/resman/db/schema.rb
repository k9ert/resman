# This file is autogenerated. Instead of editing this file, please use the
# migrations feature of ActiveRecord to incrementally modify your database, and
# then regenerate this schema definition.

ActiveRecord::Schema.define(:version => 7) do

  create_table "courses", :force => true do |t|
    t.column "name", :string
  end

  create_table "events", :force => true do |t|
    t.column "date",             :date
    t.column "start_time",       :time
    t.column "end_time",         :time
    t.column "schedulable_id",   :integer
    t.column "schedulable_type", :string
    t.column "lock_version",     :integer, :default => 0
  end

  create_table "eventseries", :force => true do |t|
    t.column "schedulable_id",    :integer
    t.column "schedulable_type",  :string
    t.column "start_date",        :date
    t.column "start_time",        :time
    t.column "end_time",          :time
    t.column "events_count",      :integer
    t.column "end_date",          :date
    t.column "gen_type",          :string
    t.column "daily_each",        :integer
    t.column "daily_kind_of_day", :string
    t.column "weekly_each",       :integer
    t.column "weekly_mon",        :boolean
    t.column "weekly_tue",        :boolean
    t.column "weekly_wed",        :boolean
    t.column "weekly_thu",        :boolean
    t.column "weekly_fri",        :boolean
    t.column "weekly_sat",        :boolean
    t.column "weekly_sun",        :boolean
  end

  create_table "resource_uses", :force => true do |t|
    t.column "event_id",    :integer
    t.column "resource_id", :integer
    t.column "collision",   :boolean
  end

  create_table "resources", :force => true do |t|
    t.column "name", :string
  end

end
