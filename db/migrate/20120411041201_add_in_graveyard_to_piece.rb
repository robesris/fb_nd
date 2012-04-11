class AddInGraveyardToPiece < ActiveRecord::Migration
  def change
    add_column :pieces, :in_graveyard, :boolean
  end
end
