class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.column :date, :date
      t.column :start_time, :time
      t.column :end_time, :time
    end
  end

  def self.down
    drop_table :events
  end
end
