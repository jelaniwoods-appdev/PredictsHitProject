class CreateMemberships < ActiveRecord::Migration[6.0]
  def change
    create_table :memberships do |t|
      t.string :goes_to
      t.string :category
      t.belongs_to :users
      t.belongs_to :clubs

      t.timestamps
    end
  end
end
