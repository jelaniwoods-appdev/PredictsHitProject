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
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :seasons

  validates_presence_of :title

  mount_uploader :picture, PictureUploader
end
