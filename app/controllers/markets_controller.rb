class MarketsController < ApplicationController

  def index
    @memberships = Membership.where({ :user_id => current_user.id, :goes_to => "seasons_table" }).order({ :club_id => :asc, :season_id => :asc })
    @m_count = 0
    @memberships.each do |member_check|
      Season.where({ :id => member_check.season_id }).at(0).markets.each do |market_count|
        @m_count = @m_count + 1
      end
    end
  end

  def update
    @market = Market.find(params[:id])
    @market.assign_attributes(market_params.slice(:title, :description, :picture))
    
    #Confirm user submitting form is the Season owner of the Market
    @owner_user_id = Membership.where({ :season_id => @market.season.id, :goes_to => "seasons_table", :category => "owner"}).at(0).user_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
    else
      if @market.save
        flash[:notice] = "Market details were successfully updated!"
      else
        flash[:alert] = "Market details were not updated. Please include a title."
      end

    end

    redirect_to("/markets/" + @market.id.to_s)
  end

  def show
    @market = Market.find(params[:id])

    @contracts = @market.contracts.order({ :created_at => :asc })
    @season_memberships = @market.season.memberships
    @club_memberships = @market.season.club.memberships

    #relevant messages
    @market_messages_all = @market.chats.order(created_at: :desc)
    @market_messages_latest = @market_messages_all.first(50).reverse

    if @season_memberships.where({ :user_id => current_user.id}).empty?
      flash[:alert] = "You are not authorized to view this page."
      redirect_to root_path
    else
      @membership_id = Membership.where({ :user_id => current_user.id, :season_id => @market.season.id }).at(0).id
      #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners. Note: this is based on season ownership as there is no special ownership of markets.
      @owner_user_id = @season_memberships.where(category: "owner").first.try(:user_id)
      @club_owner_user_id = @club_memberships.where(category: "owner").first.try(:user_id)
    end
    
  end
  
  def new
    @user_season_memberships = Membership.where({ :user_id => current_user.id, :goes_to => "seasons_table", :category => "owner"}).or(Membership.where({ :user_id => current_user.id, :goes_to => "seasons_table", :category => "admin"})).order({ :club_id => :asc })
  end


  def create
    season_id = params.fetch("season_id")
    #Confirm user submitting form is the owner of the Season the market is being created for
    @owner_user_id = Membership.where({ :season_id => season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).user_id
    
    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/markets/new")
    else
      #Create a new market and pass in the form fields
      @new_market = Market.new(market_params)
      @new_market.status = "active"
      if @new_market.save
        flash[:notice] = "Market successfully created!" 
        redirect_to("/markets/" + @new_market.id.to_s)
      else
        flash[:alert] = "Market creation was unsuccessful. Please enter a title." 
        redirect_to("/seasons/" + season_id.to_s)
      end
      
    end
    
  end


  def close_market
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    market_id = params.fetch("market_id")
    @market = Market.where({ :id => market_id }).at(0)
    @contracts = @market.contracts
    @memberships = Membership.where({ :season_id => season_id, :goes_to => "seasons_table"})

    #Confirm user submitting form is the Season owner of the Market and that the Market is not already closed
    @owner_user_id = Membership.where({ :season_id => @market.season.id, :goes_to => "seasons_table", :category => "owner"}).at(0).user_id

    if (@market.status == "closed") || (@owner_user_id != current_user.id)
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/markets/" + market_id.to_s)
    else

      #For each contract in the market, determine final resolution

      @contracts.each do |contract_x|
        contract_outcome =  params.fetch(contract_x.id.to_s)
        if contract_outcome == "no"
          #determine rows in asset table associated with this contract (no)
          assets = Asset.where({ :contract_id => contract_x.id, :category => "contract_quantity_b"})

          #run loop on each relevant asset row to 1) determine quantity associated with each membership and then 2) to add to season fund to the relevant membership
          assets.each do |payout_contract|
            amount = payout_contract.quantity #for now assume always 1 to 1 relationship. Can always add factor to adjust quantity if necessary

            #find associated season_fund row for this membership
            season_fund = Asset.where({ :membership_id => payout_contract.membership_id, :category => "season_fund"}).at(0)

            #Add amount associated with contract to season_fund for each relevant membership
            season_fund.quantity = season_fund.quantity + amount
            season_fund.save

          end

          contract_x.status = "closed"
          contract_x.save
          
        elsif contract_outcome == "yes" #consider adding 'and' conditional that contract is active to prevent potential double counting/erros
          #determine rows in asset table associated with this contract (yes)
          assets = Asset.where({ :contract_id => contract_x.id, :category => "contract_quantity_a"})

          #run loop on each relevant asset row to 1) determine quantity associated with each membership and then 2) to add to season fund to the relevant membership
          assets.each do |payout_contract|
            amount = payout_contract.quantity #for now assume always 1 to 1 relationship. Can always add factor to adjust quantity if necessary

            #find associated season_fund row for this membership
            season_fund = Asset.where({ :membership_id => payout_contract.membership_id, :category => "season_fund"}).at(0)

            #Add amount associated with contract to season_fund for each relevant membership
            season_fund.quantity = season_fund.quantity + amount
            season_fund.save

          end
          contract_x.status = "closed"
          contract_x.save
        end
        #now that funds have been distributed to season fund, clear all asset ownership of this contract
        all_assets = Asset.where({ :contract_id => contract_x.id})
        all_assets.each do |remove_contract_ownership|
          remove_contract_ownership.destroy
        end
      end

      #convert each user's contract quantities into season funds based on the final resoultion
      
      #change market status to closed
      @market.status = "closed"
      @market.save


      flash[:notice] = "Market has been successfully closed!"
      redirect_to("/markets/" + market_id.to_s)

    end

  end

  def pause_market
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
    @market = Market.where({ :id => @market_id }).at(0)
  
    #Confirm user submitting form is the Season owner of the Market and that the Market is active
    @owner_user_id = Membership.where({ :season_id => @market.season.id, :goes_to => "seasons_table", :category => "owner"}).at(0).user_id

    if (@market.status != "active") || (@owner_user_id != current_user.id)
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/markets/" + @market_id.to_s)
    else
    

      paused_market = @market
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
      redirect_to("/markets/" + @market_id.to_s)

    end
    
  end

  def unpause_market
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
    @market = Market.where({ :id => @market_id }).at(0)
  
    #Confirm user submitting form is the Season owner of the Market and that the Market is paused
    @owner_user_id = Membership.where({ :season_id => @market.season.id, :goes_to => "seasons_table", :category => "owner"}).at(0).user_id

    if (@market.status != "paused") || (@owner_user_id != current_user.id)
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/markets/" + @market_id.to_s)
    else

      unpaused_market = @market
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
      redirect_to("/markets/" + @market_id.to_s)
    
    end

  end


  private

  def market_params
    params.permit(:title, :description, :picture, :id, :_method, :season_id, :category)
  end

end
