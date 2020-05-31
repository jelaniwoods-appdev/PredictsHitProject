class MarketController < ApplicationController

  def show_markets
    @membership_rows = Membership.where({ :users_id => current_user.id, :goes_to => "seasons_table" })
    render({ :template => "market_templates/show_market_memberships.html.erb" })
  end

  def view_market

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