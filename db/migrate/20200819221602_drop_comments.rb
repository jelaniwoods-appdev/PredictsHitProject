class DropComments < ActiveRecord::Migration[6.0]
  def change
    drop_table :comments
    drop_table :comment_hierarchies
  end
end
