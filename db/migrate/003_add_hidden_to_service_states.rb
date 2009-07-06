class AddHiddenToServiceStates < ActiveRecord::Migration
  def self.up
    add_column :service_states, :hidden, :boolean, :default => false
    ServiceState.update_all(['hidden = ?', false])
  end

  def self.down
    remove_column :service_states, :hidden
  end
end

