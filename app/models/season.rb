# == Schema Information
#
# Table name: seasons
#
#  id          :integer          not null, primary key
#  description :text
#  password    :string
#  picture     :string
#  status      :string
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  club_id     :integer
#
# Indexes
#
#  index_seasons_on_club_id  (club_id)
#

class Season < ApplicationRecord
  belongs_to :club
  has_many :markets
  has_many :memberships
  has_many :users, :through => :memberships
end
