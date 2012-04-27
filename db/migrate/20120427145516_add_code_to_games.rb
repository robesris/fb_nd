class AddCodeToGames < ActiveRecord::Migration
  def change
    add_column :games, :code, :string
  end
end
