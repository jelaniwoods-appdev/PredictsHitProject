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

  #buy/sell contracts 
  #currently only allow buying/selling one at a time. Update later to allow number entry
  #later update so the buy/sell/yes/no are separate controllers which inherit from one?

  def buy_yes_contracts
    #set variables
    @contract_id = params.fetch("contract_id")
    @contract_row = Contract.where({ :id => @contract_id }).at(0)
    @market_id = @contract_row.market.id
    @season_id = @contract_row.market.season.id
    @club_id = @contract_row.market.season.club.id
    @number_of_contracts = params.fetch("quantity_buy_yes")
    @starting_contract_price = @contract_row.price
    @membership_row = Membership.where({ :users_id => current_user.id, :seasons_id => @season_id, :goes_to => "seasons_table"}).at(0)
    @user_asset_rows = @membership_row.assets
    @user_season_funds_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :category => "season_fund"}).at(0)
    @user_starting_season_funds = @user_season_funds_row.quantity
    @starting_contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity"}).at(0) #membership_row.id is probably unnecessary.
    asset_quantity_counter = 0

    #check if user already has an asset row associated with this contract (contract id matches and category is "contract_quantity").
    #If user does, skip step, otherwise, if user does not, create a new asset with a quantity of 0.
    if @starting_contract_asset_row.present?
    else
      new_asset = Asset.new
      new_asset.membership_id = @membership_row.id
      new_asset.season_id = @season_id
      new_asset.contract_id = @contract_id
      new_asset.category = "contract_quantity"
      new_asset.quantity = 0
      new_asset.save
    end

    #add variable to track contract_asset_row now that we know it must exist:
    @contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity"}).at(0) #membership_row.id is probably unnecessary.
    
    #check if user has sufficient funds to buy one contract. If not, return them to the screen and alert them of insufficient funds.
    if @user_starting_season_funds < @starting_contract_price
      flash[:alert] = "Insufficient funds. Sell some assets or request more money from Season owner."
      redirect_to("/markets/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s)
      return
    else
      #(1) remove funds from user's season_funds, (2) add contract asset, (3) update contract price based on algorithm, (4)later, make it so this is reflected in transaction table(probably in a first step and base everything off transaction)
      
      #remove funds from user's season_funds
      @user_season_funds_row.quantity = @user_season_funds_row.quantity - @starting_contract_price
      @user_season_funds_row.save

      #update contract quantity to reflect new purchase
      @contract_asset_row.quantity = @contract_asset_row.quantity + 1
      @contract_asset_row.save

      #update contract price based on algorithm. Start with simple algorithm that only adds 0.01 to contract price each time one is purchased.
      @contract_row.price = @starting_contract_price + 0.01
      @contract_row.save

    end


    flash[:notice] = @number_of_contracts + " contract(s) sucessfully purchased!"

    redirect_to("/markets/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s)
  end

  def buy_no_contracts
    @number_of_contracts = params.fetch("quantity_buy_no")

  end

  def sell_yes_contracts
    @number_of_contracts = params.fetch("quantity_sell_yes")

  end

  def sell_no_contracts
    @number_of_contracts = params.fetch("quantity_sell_no")

  end

end