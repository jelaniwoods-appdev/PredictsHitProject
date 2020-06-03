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

    #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners. Note: this is based on season ownership as there is no special ownership of markets.
    @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

    render({ :template => "market_templates/market_details.html.erb" })
  end
  
  def market_create_form
    render({ :template => "market_templates/create_market_page.html.erb" })
  end

  def create_market
    #Create a new market and pass in the form fields
    @new_market = Market.new
    @new_market.season_id = params.fetch("associated_season_id")
    @new_market.title = params.fetch("market_title")
    @new_market.description = params.fetch("market_description")
    @new_market.price = params.fetch("market_price")
    @new_market.quantity = params.fetch("market_quantity")
    @new_market.status = "active"
    @new_market.save
    
    redirect_to("/")
  end


end