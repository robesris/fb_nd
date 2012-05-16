class AddCheckingForEventsToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :checking_for_events, :boolean
  end
end
