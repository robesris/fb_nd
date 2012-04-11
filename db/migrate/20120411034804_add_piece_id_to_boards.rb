class AddPieceIdToBoards < ActiveRecord::Migration
  def change
    add_column :boards, :piece_id, :integer
  end
end
