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
#  club_id    :integer
#  goes_to_id :integer
#  market_id  :integer
#  season_id  :integer
#  user_id    :integer
#
# Indexes
#
#  index_chats_on_club_id    (club_id)
#  index_chats_on_market_id  (market_id)
#  index_chats_on_season_id  (season_id)
#  index_chats_on_user_id    (user_id)
#

class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :club
  belongs_to :season
  belongs_to :market
end
