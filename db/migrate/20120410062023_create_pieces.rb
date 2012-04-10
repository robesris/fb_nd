class CreatePieces < ActiveRecord::Migration
  def change
    create_table :pieces do |t|
      t.string :name
      t.integer :player_id
      t.integer :row
      t.integer :col
      t.boolean :flipped
      t.string :type

      t.timestamps
    end
  end
end
