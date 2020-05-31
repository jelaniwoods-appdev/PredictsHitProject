class CreateContracts < ActiveRecord::Migration[6.0]
  def change
    create_table :contracts do |t|
      t.string :status
      t.string :title
      t.text :description
      t.decimal :price
      t.references :market, index:true

      t.timestamps
    end
  end
end
