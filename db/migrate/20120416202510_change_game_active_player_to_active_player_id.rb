class ChangeGameActivePlayerToActivePlayerId < ActiveRecord::Migration
  def up
    rename_column :games, :active_player, :active_player_id
  end

  def down
    rename_column :games, :active_player_id, :active_player
  end
end
