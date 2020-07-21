class MarketController < ApplicationController

  def show_markets
    @membership_rows = Membership.where({ :users_id => current_user.id, :goes_to => "seasons_table" }).order({ :clubs_id => :asc, :seasons_id => :asc })
    @m_count = 0
    @membership_rows.each do |member_check|
      Season.where({ :id => member_check.seasons_id }).at(0).markets.each do |market_count|
        @m_count = @m_count + 1
      end
    end
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
    #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners.
    @owner_user_id = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to view this page."
      redirect_to("/")
    else
      render({ :template => "market_templates/manage_market_page.html.erb" })
    end
    
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
    #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners.
    @owner_user_id = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to view this page."
      redirect_to("/")
    else
      render({ :template => "market_templates/close_market_page.html.erb" })
    end
    
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
        #determine rows in asset table associated with this contract (no)
        asset_rows = Asset.where({ :contract_id => contract_x.id, :category => "contract_quantity_b"})

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
        
      elsif contract_outcome == "yes" #consider adding 'and' conditional that contract is active to prevent potential double counting/erros
        #determine rows in asset table associated with this contract (yes)
        asset_rows = Asset.where({ :contract_id => contract_x.id, :category => "contract_quantity_a"})

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
      #now that funds have been distributed to season fund, clear all asset ownership of this contract
      all_asset_rows = Asset.where({ :contract_id => contract_x.id})
      all_asset_rows.each do |remove_contract_ownership|
        remove_contract_ownership.destroy
      end
    end

    #convert each user's contract quantities into season funds based on the final resoultion
    
    #change market status to closed
    @market_row.status = "closed"
    @market_row.save


    flash[:notice] = "Market has been successfully closed!"
    redirect_to("/markets/" + club_id.to_s + "/" + season_id.to_s + "/" + market_id.to_s)
  end

  def pause_market_action
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
  
    paused_market = Market.where({ :id => @market_id }).at(0)
    paused_market_contracts = paused_market.contracts

    #pause market
    paused_market.status = "paused"
    paused_market.save

    #pause each contract
    paused_market_contracts.each do |pause_contract|
      pause_contract.status = "paused"
      pause_contract.save
    end
    flash[:notice] = "Market was successfully paused!"
    redirect_to("/markets/" + @club_id.to_s + "/"+ @season_id.to_s + "/"+ @market_id.to_s)
    
  end

  def unpause_market_action
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
  
    unpaused_market = Market.where({ :id => @market_id }).at(0)
    unpaused_market_contracts = unpaused_market.contracts

    #unpause market
    unpaused_market.status = "active"
    unpaused_market.save
    
    #unpause each contract
    unpaused_market_contracts.each do |unpause_contract|
      unpause_contract.status = "active"
      unpause_contract.save
    end

    flash[:notice] = "Market was successfully unpaused!"
    redirect_to("/markets/" + @club_id.to_s + "/"+ @season_id.to_s + "/"+ @market_id.to_s)
    
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
    if params[:updated_market_picture].present?
      updated_market_details.picture = params.fetch("updated_market_picture")
    end
    if updated_market_details.valid?
      updated_market_details.save

      flash[:notice] = "Market details were successfully updated!"
      redirect_to("/markets/" + @club_id.to_s + "/"+ @season_id.to_s + "/"+ @market_id.to_s)
    else
      flash[:alert] = "Market details were not updated. Please include a title."
      redirect_to("/markets/" + @club_id.to_s + "/"+ @season_id.to_s + "/"+ @market_id.to_s)
    end
    
  end

  def view_market
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")

    @club_row = Club.where({ :id => @club_id }).at(0)
    @season_row = Season.where({ :id => @season_id}).at(0)
    @market_row = Market.where({ :id => @market_id}).at(0)
    @contract_rows = @market_row.contracts.order({ :created_at => :asc })
    @season_membership_rows = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table"})


    #relevant comments
    @market_comments = Comment.where({ :markets_id => @market_id, :goes_to => "market" }).hash_tree

    if @season_membership_rows.where({ :users_id => current_user.id}).empty?
      flash[:alert] = "You are not authorized to view this page."
      redirect_to("/")
    else
      #determine current user asset quantities (this seems unnecessary because i could just call current_user.id. Think through and decide whether to update.)
      @membership_id = Membership.where({ :users_id => current_user.id, :seasons_id => @season_id }).at(0).id
      #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners. Note: this is based on season ownership as there is no special ownership of markets.
      @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id
      @club_owner_user_id = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :category => "owner"}).at(0).users_id

      render({ :template => "market_templates/market_details.html.erb" })
    end
    
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
    @new_market.category = params.fetch("market_category")
      #see relevant html.erb page for note on these. uncomment if change there
        #@new_market.price = params.fetch("market_price")
        #@new_market.quantity = params.fetch("market_quantity")
    @new_market.status = "active"
    if params[:market_picture].present?
      @new_market.picture = params.fetch("market_picture")
    end
    if @new_market.valid?
      @new_market.save
      flash[:notice] = "Market successfully created!" 
      redirect_to("/markets/" + @new_market.season.club.id.to_s + "/" + @new_market.season.id.to_s + "/" + @new_market.id.to_s)
    else
      flash[:alert] = "Market creation was unsuccessful. Please enter a title." 
      redirect_to("/new_market")
    end
    
    
  end

end