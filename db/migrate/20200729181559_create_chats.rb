class CreateChats < ActiveRecord::Migration[6.0]
  def change
    create_table :chats do |t|
      t.text :body
      t.integer :likes
      t.string :status
      t.string :goes_to
      t.integer :goes_to_id
      t.belongs_to :users
      t.belongs_to :clubs
      t.belongs_to :seasons
      t.belongs_to :markets

      t.timestamps
    end
  end
end
