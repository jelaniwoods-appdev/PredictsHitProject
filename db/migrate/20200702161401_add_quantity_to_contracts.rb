class AddQuantityToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :quantity_a, :integer
    add_column :contracts, :quantity_b, :integer
    add_column :contracts, :category, :string
  end
end
