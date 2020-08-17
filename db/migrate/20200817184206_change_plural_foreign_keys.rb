class ChangePluralForeignKeys < ActiveRecord::Migration[6.0]
  def change
    rename_column :memberships, :clubs_id, :club_id
    rename_column :memberships, :users_id, :user_id
    rename_column :memberships, :seasons_id, :season_id

    rename_column :chats, :clubs_id, :club_id
    rename_column :chats, :users_id, :user_id
    rename_column :chats, :seasons_id, :season_id
    rename_column :chats, :markets_id, :market_id

    rename_column :comments, :clubs_id, :club_id
    rename_column :comments, :users_id, :user_id
    rename_column :comments, :seasons_id, :season_id
    rename_column :comments, :markets_id, :market_id
  end
end
