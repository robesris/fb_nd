class AddPlayerIdToSpace < ActiveRecord::Migration
  def change
    add_column :spaces, :player_id, :integer
  end
end
