class AddSummonSpaceToSpaces < ActiveRecord::Migration
  def change
    add_column :spaces, :summon_space, :integer
  end
end
