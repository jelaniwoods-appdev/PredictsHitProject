# == Schema Information
#
# Table name: chats
#
#  id         :integer          not null, primary key
#  body       :text
#  goes_to    :string
#  likes      :integer
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  clubs_id   :integer
#  goes_to_id :integer
#  markets_id :integer
#  seasons_id :integer
#  users_id   :integer
#
# Indexes
#
#  index_chats_on_clubs_id    (clubs_id)
#  index_chats_on_markets_id  (markets_id)
#  index_chats_on_seasons_id  (seasons_id)
#  index_chats_on_users_id    (users_id)
#

class Chat < ApplicationRecord
  belongs_to :user, {:foreign_key => "users_id"}
  belongs_to :club, {:foreign_key => "clubs_id"}
  belongs_to :season, {:foreign_key => "seasons_id"}
  belongs_to :market, {:foreign_key => "markets_id"}
end
