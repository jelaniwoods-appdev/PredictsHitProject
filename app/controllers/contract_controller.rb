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

  def manage_contract
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    market_id = params.fetch("market_id")
    contract_id = params.fetch("contract_id")

    @club_row = Club.where({ :id => club_id }).at(0)
    @season_row = Season.where({ :id => season_id }).at(0)
    @market_row = Market.where({ :id => market_id }).at(0)
    @contract_row = Contract.where({ :id => contract_id }).at(0)
    @membership_rows = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table"})

    render({ :template => "contract_templates/manage_contract_page.html.erb" })
  end


  def view_contract
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
    @contract_id = params.fetch("contract_id")

    @club_row = Club.where({ :id => @club_id }).at(0)
    @season_row = Season.where({ :id => @season_id}).at(0)
    @market_row = Market.where({ :id => @market_id}).at(0)
    @contract_row = Contract.where({ :id => @contract_id}).at(0)
    @membership_rows = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table"})

    #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners. Note: this is based on season ownership as there is no special ownership of markets/contracts.
    @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

    render({ :template => "contract_templates/contract_details.html.erb" })
  end

  def update_contract_details
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
    @contract_id = params.fetch("contract_id")
    @updated_title = params.fetch("updated_contract_title")
    @updated_description = params.fetch("updated_contract_description")
  
    updated_contract_details = Contract.where({ :id => @contract_id }).at(0)
    updated_contract_details.title = @updated_title
    updated_contract_details.description = @updated_description
    updated_contract_details.save

    flash[:notice] = "Contract Details were successfully updated!"
    redirect_to("/contracts/manage/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s + "/" + @contract_id.to_s)
  end

end