# == Schema Information
#
# Table name: comments
#
#  id            :integer          not null, primary key
#  body          :text
#  comment_index :integer
#  goes_to       :string
#  status        :string
#  title         :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  clubs_id      :integer
#  markets_id    :integer
#  seasons_id    :integer
#  users_id      :integer
#
# Indexes
#
#  index_comments_on_clubs_id    (clubs_id)
#  index_comments_on_markets_id  (markets_id)
#  index_comments_on_seasons_id  (seasons_id)
#  index_comments_on_users_id    (users_id)
#

class Comment < ApplicationRecord
  belongs_to :user, {:foreign_key => "users_id"}
  belongs_to :club, {:foreign_key => "clubs_id"}
  belongs_to :season, {:foreign_key => "seasons_id"}
  belongs_to :market, {:foreign_key => "markets_id"}
  
end
