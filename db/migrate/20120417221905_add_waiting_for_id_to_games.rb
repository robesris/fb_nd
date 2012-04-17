class AddWaitingForIdToGames < ActiveRecord::Migration
  def change
    add_column :games, :waiting_for_id, :integer
  end
end
