class AddPieceIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :piece_id, :integer
  end
end
