class ContractController < ApplicationController

  def add_contract
    #Create a new market and pass in the form fields
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")

    @new_contract = Contract.new
    @new_contract.title =  params.fetch("contract_title")
    @new_contract.description = params.fetch("contract_description")
    @new_contract.price = params.fetch("contract_starting_price")
    @new_contract.status = "active"
    @new_contract.market_id = @market_id
    @new_contract.save

    redirect_to("/markets/manage/" + @club_id + "/" + @season_id + "/" + @market_id)
  end

end