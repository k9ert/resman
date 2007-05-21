class CreateEventPayloads < ActiveRecord::Migration
  def self.up
    create_table :event_payloads do |t|
      t.column :event_id, :integer
      t.column :payload1, :integer
      t.column :payload2, :string
    end
  end

  def self.down
    drop_table :event_payloads
  end
end
