# == Schema Information
#
# Table name: memberships
#
#  id         :integer          not null, primary key
#  category   :string
#  goes_to    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  clubs_id   :integer
#  seasons_id :integer
#  users_id   :integer
#
# Indexes
#
#  index_memberships_on_clubs_id    (clubs_id)
#  index_memberships_on_seasons_id  (seasons_id)
#  index_memberships_on_users_id    (users_id)
#

class Membership < ApplicationRecord
  belongs_to :user, {:foreign_key => "users_id"}
  belongs_to :club, {:foreign_key => "clubs_id"}
  belongs_to :season, {:foreign_key => "seasons_id"}
  has_many :assets

  validates :users_id, uniqueness: {scope: [:goes_to, :clubs_id , :seasons_id ]}
end
