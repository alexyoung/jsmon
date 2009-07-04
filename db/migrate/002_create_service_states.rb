class CreateServiceStates < ActiveRecord::Migration
  def self.up
    create_table :service_states do |t|
      t.integer :service_id
      t.text :info
      t.string :state
      t.integer :exit_code
      t.timestamps
    end
  end

  def self.down
    drop_table :service_states
  end
end
