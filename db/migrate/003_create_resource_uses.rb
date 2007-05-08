class CreateResourceUses < ActiveRecord::Migration
  def self.up
    create_table :resource_uses do |t|
      t.column :event_id, :integer
      t.column :resource_id, :integer
    end
  end

  def self.down
    drop_table :resource_uses
  end
end
