class AddHalfCrystalToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :half_crystal, :boolean
  end
end
