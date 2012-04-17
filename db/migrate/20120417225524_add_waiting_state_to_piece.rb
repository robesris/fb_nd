class AddWaitingStateToPiece < ActiveRecord::Migration
  def change
    add_column :pieces, :waiting_state, :string
  end
end
