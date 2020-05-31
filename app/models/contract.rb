# == Schema Information
#
# Table name: contracts
#
#  id          :integer          not null, primary key
#  description :text
#  price       :decimal(, )
#  status      :string
#  title       :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  market_id   :integer
#
# Indexes
#
#  index_contracts_on_market_id  (market_id)
#

class Contract < ApplicationRecord
  belongs_to :market
end
