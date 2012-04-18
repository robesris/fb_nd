class AddActivePieceIdToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :active_piece_id, :integer
  end
end
