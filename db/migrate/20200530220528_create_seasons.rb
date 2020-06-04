class CreateSeasons < ActiveRecord::Migration[6.0]
  def change
    create_table :seasons do |t|
      t.string :status
      t.string :title
      t.text :description
      t.decimal :fund
      t.string :picture
      t.string :password
      t.references :club, index:true

      t.timestamps
    end
  end
end
