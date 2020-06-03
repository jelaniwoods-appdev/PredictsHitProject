# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  category               :string
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  prof_pic               :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  validates_uniqueness_of :username
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  

  has_many :memberships
  has_many :clubs, :through => :memberships
  has_many :seasons, :through => :memberships
end
