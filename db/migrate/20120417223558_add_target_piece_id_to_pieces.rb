class AddTargetPieceIdToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :target_piece_id, :integer
  end
end
