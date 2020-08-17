# == Schema Information
#
# Table name: clubs
#
#  id          :integer          not null, primary key
#  description :text
#  password    :string
#  picture     :string
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Club < ApplicationRecord
  has_many :memberships, -> { where(goes_to: 'clubs_table') }
  has_many :users, :through => :memberships
  has_many :seasons
  has_many :chats, -> { where(goes_to: 'clubs_table') }

  validates_presence_of :title

  mount_uploader :picture, PictureUploader
end
