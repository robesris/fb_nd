class AddBoardIdToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :board_id, :integer
  end
end
