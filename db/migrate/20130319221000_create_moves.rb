class CreateMoves < ActiveRecord::Migration
  def change
    create_table :moves do |t|
      t.integer :player_id
      t.integer :piece_id
      t.integer :space_id
      t.boolean :earn_crystals, :default => true
      t.boolean :capture_allowed, :default => true
      t.boolean :pass

      t.timestamps
    end
  end
end
