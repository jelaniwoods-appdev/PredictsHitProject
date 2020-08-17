# == Schema Information
#
# Table name: comments
#
#  id         :integer          not null, primary key
#  body       :text
#  goes_to    :string
#  status     :string
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  club_id    :integer
#  goes_to_id :integer
#  market_id  :integer
#  parent_id  :integer
#  season_id  :integer
#  user_id    :integer
#
# Indexes
#
#  index_comments_on_club_id    (club_id)
#  index_comments_on_market_id  (market_id)
#  index_comments_on_season_id  (season_id)
#  index_comments_on_user_id    (user_id)
#

class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :club
  belongs_to :season
  belongs_to :market

  acts_as_tree order: 'created_at DESC'
  
end
