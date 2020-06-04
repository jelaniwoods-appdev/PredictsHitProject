class CreateAssets < ActiveRecord::Migration[6.0]
  def change
    create_table :assets do |t|
      t.string :category
      t.decimal :quantity
      t.references :user, index:true
      t.references :season, index:true
      t.references :contract, index:true

      t.timestamps
    end
  end
end
