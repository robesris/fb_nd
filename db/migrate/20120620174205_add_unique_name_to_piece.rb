class AddUniqueNameToPiece < ActiveRecord::Migration
  def change
    add_column :pieces, :unique_name, :string
  end
end
