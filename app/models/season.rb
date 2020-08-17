# == Schema Information
#
# Table name: seasons
#
#  id          :integer          not null, primary key
#  description :text
#  fund        :decimal(, )
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

  scope :open, -> { where.not(status: 'closed') }
  scope :closed, -> { where(status: 'closed') }

  validates :fund, :numericality => true
  validates_presence_of :title
  
  mount_uploader :picture, PictureUploader

end
