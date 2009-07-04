class CreateServices < ActiveRecord::Migration
  def self.up
    create_table :services do |t|
      t.string :code
      t.text :description
      t.text :name
      t.timestamps
    end
  end

  def self.down
    drop_table :services
  end
end
