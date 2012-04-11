class RemoveRowAndColFromPieces < ActiveRecord::Migration
  def up
    remove_column :pieces, :row
    remove_column :pieces, :col
  end

  def down
    add_column :pieces, :row, :integer
    add_column :pieces, :col, :integer
  end
end
