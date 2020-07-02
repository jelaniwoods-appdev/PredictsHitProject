class AddQuantityToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :quantity, :integer
  end
end
