class AddPhaseToGame < ActiveRecord::Migration
  def change
    add_column :games, :phase, :string
  end
end
