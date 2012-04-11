class CreateSpaces < ActiveRecord::Migration
  def change
    create_table :spaces do |t|
      t.integer :row
      t.integer :col
      t.integer :piece_id
      t.integer :board_id

      t.timestamps
    end
  end
end
