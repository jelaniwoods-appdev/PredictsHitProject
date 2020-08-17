class HomeController < ApplicationController
  skip_before_action :authenticate_user!, except: [:show_getting_started]
  def show_homepage
    render({ :template => "home_templates/index.html.erb" })
  end

  def show_faq
    render({ :template => "home_templates/faq.html.erb" })
  end

  def show_about
    render({ :template => "home_templates/about.html.erb" })
  end

  def show_support
    render({ :template => "home_templates/support.html.erb" })
  end

  def show_global_markets
    render({ :template => "home_templates/global_markets.html.erb" })
  end

  def show_getting_started
    render({ :template => "home_templates/getting_started.html.erb" })
  end

  def create_starter_market
    
    #Create new club and new club membership with user as owner
    @new_club = Club.new
    @new_club.title = params.fetch("club_title")
    if @new_club.valid?
      @new_club.save
      #Create a new membership to this club and assign the creator of the club to be the 'owner'
      @new_membership = Membership.new
      @new_membership.user_id = current_user.id
      @new_membership.club_id = @new_club.id
      @new_membership.goes_to = "clubs_table"
      @new_membership.category = "owner"
      @new_membership.save
      
    else
      flash[:alert] = "Market creation was unsuccessful. Please make sure you entered in a Club title." 
      redirect_to("/getting_started")
    end

    #Create new season, new season membership with user as owner, and assets with season fund amount
    @new_season = Season.new
    @new_season.club_id = @new_club.id
    @new_season.title = params.fetch("season_title")
    @new_season.fund = params.fetch("season_fund")
    @new_season.status = "active"
    if @new_season.valid?
      @new_season.save

      @new_membership = Membership.new
      @new_membership.user_id = current_user.id
      @new_membership.season_id = @new_season.id
      @new_membership.club_id = @new_club.id
      @new_membership.goes_to = "seasons_table"
      @new_membership.category = "owner"
      @new_membership.save
      
      @new_asset = Asset.new
      @new_asset.membership_id = @new_membership.id
      @new_asset.season_id = @new_season.id
      @new_asset.category = "season_fund"
      @new_asset.quantity = params.fetch("season_fund")
      @new_asset.save

    else
      if params.fetch("season_title").present?
        flash[:alert] = "Market creation was unsuccessful. Please enter a numerical amount of money for season participants to start with. If you do not want to give participants money yet, please enter 0."
      else
        flash[:alert] = "Market creation was unsuccessful. Please provide a title for your Season."
      end
      redirect_to("/getting_started")
    end

    #Create a new market 
    @new_market = Market.new
    @new_market.season_id = @new_season.id
    @new_market.title = params.fetch("market_title")
    @new_market.category = "Independent"
    @new_market.status = "active"
    if @new_market.valid?
      @new_market.save
    else
      flash[:alert] = "Market creation was unsuccessful. Please enter a title for your Market." 
      redirect_to("/getting_started")
    end

    #Create a new contract
    @new_contract = Contract.new
    @new_contract.market_id = @new_market.id
    @new_contract.title =  params.fetch("contract_title")
    @new_contract.quantity_a = 0
    @new_contract.quantity_b = 0
    @new_contract.category = @new_contract.market.category
    @new_contract.status = "active"

    if @new_contract.valid?
      @new_contract.save
      flash[:notice] = "Your Market was successfully created!" 
      redirect_to("/markets/" + @new_club.id.to_s + "/" + @new_season.id.to_s + "/" + @new_market.id.to_s)
    else
      flash[:alert] = "Market creation was unsuccessful. Please enter a title for your Contract."
      redirect_to("/getting_started")
    end

  end



end
