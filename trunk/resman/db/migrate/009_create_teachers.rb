class CreateTeachers < ActiveRecord::Migration
  def self.up
    create_table :teachers do |t|
      t.column :given_name, :string
      t.column :surname, :string
    end
  end

  def self.down
    drop_table :teachers
  end
end
