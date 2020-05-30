class CreateAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :accounts do |t|
      t.string :username
      t.string :prof_pic
      t.string :category
      t.references :user, index:true

      t.timestamps
    end
  end
end
