# == Schema Information
#
# Table name: markets
#
#  id          :integer          not null, primary key
#  description :text
#  password    :string
#  picture     :string
#  price       :decimal(, )
#  quantity    :decimal(, )
#  status      :string
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  season_id   :integer
#
# Indexes
#
#  index_markets_on_season_id  (season_id)
#

class Market < ApplicationRecord

  belongs_to :season
  has_many :contracts

end
