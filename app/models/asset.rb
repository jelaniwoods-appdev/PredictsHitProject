# == Schema Information
#
# Table name: assets
#
#  id          :integer          not null, primary key
#  category    :string
#  quantity    :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  contract_id :integer
#  season_id   :integer
#  user_id     :integer
#
# Indexes
#
#  index_assets_on_contract_id  (contract_id)
#  index_assets_on_season_id    (season_id)
#  index_assets_on_user_id      (user_id)
#

class Asset < ApplicationRecord
end
