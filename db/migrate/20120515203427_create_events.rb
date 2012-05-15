class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :game_id
      t.integer :player_num
      t.string :action
      t.string :from
      t.string :to
      t.string :options

      t.timestamps
    end
  end
end
