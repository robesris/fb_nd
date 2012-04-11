class AddActivePlayerToGame < ActiveRecord::Migration
  def change
    add_column :games, :active_player, :integer
  end
end
