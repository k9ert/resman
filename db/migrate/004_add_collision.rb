class AddCollision < ActiveRecord::Migration
  def self.up
    add_column :resource_uses, :collision, :boolean
  end

  def self.down
    remove_column :resource_uses, :collision
  end
end
