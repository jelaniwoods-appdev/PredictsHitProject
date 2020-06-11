class MarketController < ApplicationController

  def show_markets
    @membership_rows = Membership.where({ :users_id => current_user.id, :goes_to => "seasons_table" }).order({ :clubs_id => :asc, :seasons_id => :asc })
    render({ :template => "market_templates/show_market_memberships.html.erb" })
  end

  def manage_market
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    market_id = params.fetch("market_id")

    @club_row = Club.where({ :id => club_id }).at(0)
    @season_row = Season.where({ :id => season_id }).at(0)
    @market_row = Market.where({ :id => market_id }).at(0)
    @contract_rows = @market_row.contracts
    @membership_rows = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table"})

    render({ :template => "market_templates/manage_market_page.html.erb" })
  end

  def close_market_page
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    market_id = params.fetch("market_id")

    @club_row = Club.where({ :id => club_id }).at(0)
    @season_row = Season.where({ :id => season_id }).at(0)
    @market_row = Market.where({ :id => market_id }).at(0)
    @contract_rows = @market_row.contracts
    @membership_rows = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table"})

    render({ :template => "market_templates/close_market_page.html.erb" })
  end

  def close_market_action
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    market_id = params.fetch("market_id")
    @market_row = Market.where({ :id => market_id }).at(0)
    @contract_rows = @market_row.contracts
    @membership_rows = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table"})

    #For each contract in the market, determine final resolution

    @contract_rows.each do |contract_x|
      contract_outcome =  params.fetch(contract_x.id.to_s)
      if contract_outcome == "no"
        contract_x.status = "closed"
        contract_x.save
        
      elsif contract_outcome == "yes" #consider adding 'and' conditional that contract is active to prevent potential double counting/erros
        #determine rows in asset table associated with this contract
        asset_rows = Asset.where({ :contract_id => contract_x.id, :category => "contract_quantity"})

        #run loop on each relevant asset row to 1) determine quantity associated with each membership and then 2) to add to season fund to the relevant membership
        asset_rows.each do |payout_contract|
          amount = payout_contract.quantity #for now assume always 1 to 1 relationship. Can always add factor to adjust quantity if necessary

          #find associated season_fund row for this membership
          season_fund_row = Asset.where({ :membership_id => payout_contract.membership_id, :category => "season_fund"}).at(0)

          #Add amount associated with contract to season_fund for each relevant membership
          season_fund_row.quantity = season_fund_row.quantity + amount
          season_fund_row.save

        end
        contract_x.status = "closed"
        contract_x.save
      end
    end

    #convert each user's contract quantities into season funds based on the final resoultion
    
    #change market status to closed
    @market_row.status = "closed"
    @market_row.save


    flash[:notice] = "Market has been successfully closed!"
    redirect_to("/markets/manage/" + club_id.to_s + "/" + season_id.to_s + "/" + market_id.to_s)
  end





  def update_market_details
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
    @updated_title = params.fetch("updated_market_title")
    @updated_description = params.fetch("updated_market_description")
  
    updated_market_details = Market.where({ :id => @market_id }).at(0)
    updated_market_details.title = @updated_title
    updated_market_details.description = @updated_description
    updated_market_details.save

    flash[:notice] = "Market Details were successfully updated!"
    redirect_to("/markets/manage/" + @club_id.to_s + "/"+ @season_id.to_s + "/"+ @market_id.to_s)
  end

  def view_market
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")

    @club_row = Club.where({ :id => @club_id }).at(0)
    @season_row = Season.where({ :id => @season_id}).at(0)
    @market_row = Market.where({ :id => @market_id}).at(0)
    @contract_rows = @market_row.contracts
    @membership_rows = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table"})

    #determine current user asset quantities
    @membership_id = Membership.where({ :users_id => current_user.id, :seasons_id => @season_id }).at(0).id
    #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners. Note: this is based on season ownership as there is no special ownership of markets.
    @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

    render({ :template => "market_templates/market_details.html.erb" })
  end
  
  def market_create_form
    @user_id = current_user.id

    #pull the season memberships in which the user is an owner or admin for
    #see if better way to map memberships to seasons
    #later make it so only active clubs show up and/or include search option.
    @user_season_memberships = Membership.where({ :users_id => @user_id, :goes_to => "seasons_table", :category => "owner"}).or(Membership.where({ :users_id => @user_id, :goes_to => "seasons_table", :category => "admin"})).order({ :clubs_id => :asc })
    
    render({ :template => "market_templates/create_market_page.html.erb" })
  end

  def create_market
    #Create a new market and pass in the form fields
    @new_market = Market.new
    @new_market.season_id = params.fetch("associated_season_id")
    @new_market.title = params.fetch("market_title")
    @new_market.description = params.fetch("market_description")
      #see relevant html.erb page for note on these. uncomment if change there
        #@new_market.price = params.fetch("market_price")
        #@new_market.quantity = params.fetch("market_quantity")
    @new_market.status = "active"
    @new_market.save
    
    redirect_to("/markets/" + @new_market.season.club.id.to_s + "/" + @new_market.season.id.to_s + "/" + @new_market.id.to_s)
  end

end