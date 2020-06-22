class AddContractpicToContracts < ActiveRecord::Migration[6.0]
  def change
    add_column :contracts, :contractpic, :string
  end
end
