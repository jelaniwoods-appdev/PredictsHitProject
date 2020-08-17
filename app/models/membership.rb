# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  category   :string
#  goes_to    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  club_id    :integer
#  season_id  :integer
#  user_id    :integer
#
# Indexes
#
#  index_memberships_on_club_id    (club_id)
#  index_memberships_on_season_id  (season_id)
#  index_memberships_on_user_id    (user_id)
#

class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :club
  belongs_to :season
  has_many :assets

  validates :user_id, uniqueness: {scope: [:goes_to, :club_id , :season_id ]}
  extend OrderAsSpecified
  
end
