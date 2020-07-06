class AddCategoryToMarkets < ActiveRecord::Migration[6.0]
  def change
    add_column :markets, :category, :string
  end
end
