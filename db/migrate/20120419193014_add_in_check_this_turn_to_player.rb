class AddInCheckThisTurnToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :in_check_this_turn, :boolean
  end
end
