class CreateMarkets < ActiveRecord::Migration[6.0]
  def change
    create_table :markets do |t|
      t.string :status
      t.string :title
      t.text :description
      t.string :picture
      t.decimal :price
      t.decimal :quantity
      t.string :password
      t.references :season, index:true

      t.timestamps
    end
  end
end
