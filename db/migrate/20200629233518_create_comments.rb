class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.string :title
      t.string :status
      t.text :body
      t.integer :comment_index
      t.string :goes_to
      t.belongs_to :users
      t.belongs_to :clubs
      t.belongs_to :seasons
      t.belongs_to :markets

      t.timestamps
    end
  end
end
