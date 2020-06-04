# == Schema Information
#
# Table name: assets
#
#  id            :integer          not null, primary key
#  category      :string
#  quantity      :decimal(, )
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  contract_id   :integer
#  membership_id :integer
#  season_id     :integer
#
# Indexes
#
#  index_assets_on_contract_id    (contract_id)
#  index_assets_on_membership_id  (membership_id)
#  index_assets_on_season_id      (season_id)
#

class Asset < ApplicationRecord
  belongs_to :membership
end
