class AddSecretToPlayer < ActiveRecord::Migration
  def change
    add_column :players, :secret, :string
  end
end
