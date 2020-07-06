# == Schema Information
#
# Table name: contracts
#
#  id          :integer          not null, primary key
#  category    :string
#  contractpic :string
#  description :text
#  price       :decimal(, )
#  quantity_a  :integer
#  quantity_b  :integer
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
  #validates :price, :numericality => {:greater_than_or_equal_to => 0, :less_than_or_equal_to => 1}

  mount_uploader :contractpic, ContractpicUploader

  #add contract price method that shows price for buying some quantity of shares and at a specified liquidity parameter given the current shares outstanding

  def price_check(contract_id, liquidity_param, quant, choice)
    #pull in relevant contract row
    contract_row = Contract.where({ :id => contract_id }).at(0)
    
    #for classical contracts do the following:
    #need to update to account for yes vs no
    if contract_row.category == "Classical"
      #set contract contribution sum from before purchase to 0 to start
      contract_contribution_sum_pre = 0

      #calculate contract contribution sum total from before purchase
      contract_row.market.contracts.each do |contract_calc|
        contract_contibution = Math.exp((contract_calc.quantity_a.to_f / liquidity_param))
        contract_contribution_sum_pre = contract_contribution_sum_pre + contract_contibution
      end
      #calculate cost function for # of original outstanding shares
      cost_function_pre = liquidity_param * Math.log(contract_contribution_sum_pre)

      #set contract contribution sum from after purchase to 0
      contract_contribution_sum_post = 0
      #calculate contract contribution sum from after purchase for all contract except for the relevant contract
      contract_row.market.contracts.where.not({ :id => contract_id }).each do |contract_calc|
        contract_contibution = Math.exp((contract_calc.quantity_a.to_f / liquidity_param))
        contract_contribution_sum_post = contract_contribution_sum_post + contract_contibution
      end

      #add quantity user wants to purchase to the quantity for contract that user wants to purchase
      contract_contribution_sum_post = contract_contribution_sum_post + Math.exp(((contract_row.quantity_a.to_f + quant.to_f) / liquidity_param))

      #calculate cost function for desired # of new outstanding shares

      cost_function_post = liquidity_param * Math.log(contract_contribution_sum_post)

      #calculate pricefor purchase by subtracting the cost function post by the cost function pre
      price = cost_function_post - cost_function_pre

      return price

    #for Independent contracts do the following:
    elsif contract_row.category == "Independent"
      #calculate contract contribution sum total from before purchase
      cost_function_pre = liquidity_param * Math.log((Math.exp((contract_row.quantity_a.to_f / liquidity_param)) + Math.exp((contract_row.quantity_b.to_f / liquidity_param))))
      
      if choice == "yes"
        cost_function_post = liquidity_param * Math.log((Math.exp(((contract_row.quantity_a.to_f + quant.to_f)/ liquidity_param)) + Math.exp((contract_row.quantity_b.to_f / liquidity_param))))
      elsif choice == "no"
        cost_function_post = liquidity_param * Math.log((Math.exp(((contract_row.quantity_a.to_f)/ liquidity_param)) + Math.exp(((contract_row.quantity_b.to_f  + quant.to_f) / liquidity_param))))
      end
      price = cost_function_post - cost_function_pre
      return price
    end

  end

end

