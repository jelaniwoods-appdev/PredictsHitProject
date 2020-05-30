class CreateClubs < ActiveRecord::Migration[6.0]
  def change
    create_table :clubs do |t|
      t.string :title
      t.text :description
      t.string :picture
      t.string :password

      t.timestamps
    end
  end
end
