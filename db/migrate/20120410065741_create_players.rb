class CreatePlayers < ActiveRecord::Migration
  def change
    create_table :players do |t|
      t.integer :num
      t.integer :crystals

      t.timestamps
    end
  end
end
