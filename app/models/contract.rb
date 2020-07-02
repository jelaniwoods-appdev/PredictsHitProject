# == Schema Information
#
# Table name: contracts
#
#  id          :integer          not null, primary key
#  contractpic :string
#  description :text
#  price       :decimal(, )
#  quantity    :integer
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
  
  validates_presence_of :title
  validates :price, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 1}

  mount_uploader :contractpic, ContractpicUploader

  #add contract price method that shows price for buying one share at given quantities available
end
