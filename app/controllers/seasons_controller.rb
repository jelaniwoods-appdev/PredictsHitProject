class SeasonsController < ApplicationController
  
  def index
    @memberships = current_user.memberships.where(goes_to: 'seasons_table').order({ :club_id => :asc, :season_id => :asc })
  end

  def update
    @season = Season.find(params[:id])
    @season.assign_attributes(season_params.slice(:title, :description, :picture))

    if !@season.memberships.where(category: 'owner', user_id: current_user.id).exists?
      flash[:alert] = "You are not authorized to perform this action."
    else
      if @season.save
        flash[:notice] = "Season details were successfully updated!"
      else
        flash[:alert] = "Season details were not updated. Please include a title."
      end
    end

    redirect_to("/seasons/" + @season.id.to_s)
  end


  def show
    @season = Season.find(params[:id])
    @club = @season.club
    
    @current_markets = @season.markets.open.order(id: :desc)
    @closed_markets =  @season.markets.closed.order(id: :desc)
    @season_memberships = @season.memberships
    @club_memberships = @season.club.memberships

    #relevant comments
    @season_messages_all = @season.chats.order(created_at: :desc)
    @season_messages_latest = @season_messages_all.first(50).reverse

    if @season_memberships.where(user_id: current_user.id).empty?
      flash[:alert] = "You are not authorized to view this page."
      redirect_to root_path
    else
      #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners.
      @owner_user_id = @season_memberships.where(category: "owner").first.try(:user_id)
    end
  end

  def season_create_form
    @user_id = current_user.id

    #pull the club memberships in which the user is an owner or admin for
    #see if better way to map memberships to clubs
    #later make it so only active clubs show up and/or include search option.
    @user_club_memberships = Membership.where({ :user_id => @user_id, :goes_to => "clubs_table", :category => "owner"}).or(Membership.where({ :user_id => @user_id, :goes_to => "clubs_table", :category => "admin"}))
    
    render({ :template => "season_templates/create_season_page.html.erb" })
  end

  def create_season
    club_id = params.fetch("associated_club_id")
    season_title = params.fetch("season_title")
    season_description = params.fetch("season_description")
    season_fund = params.fetch("season_fund")
    
    #Confirm user submitting form is the Season owner of the Market
    @owner_user_id = Membership.where({ :club_id => club_id, :goes_to => "clubs_table", :category => "owner"}).at(0).user_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/new_season")
    else

      #Create a new season and pass in the form fields
      @new_season = Season.new
      @new_season.club_id = club_id
      @new_season.title = season_title
      @new_season.description = season_description
      @new_season.fund = season_fund
      @new_season.status = "active"
      if params[:season_picture].present?
        @new_season.picture = params.fetch("season_picture")
      end
      if @new_season.valid?
        @new_season.save
        #Create a new membership to this season and assign the creator of the season to be the 'owner'
        @new_membership = Membership.new
        @new_membership.user_id = current_user.id
        @new_membership.season_id = @new_season.id
        @new_membership.club_id = club_id
        @new_membership.goes_to = "seasons_table"
        @new_membership.category = "owner"
        @new_membership.save
        
        #Create a new asset associated to this membership based on funding amount
        @new_asset = Asset.new
        @new_asset.membership_id = @new_membership.id
        @new_asset.season_id = @new_season.id
        @new_asset.category = "season_fund"
        @new_asset.quantity = season_fund
        @new_asset.save

        flash[:notice] = "Season successfully created!" 
        redirect_to("/seasons/" + @new_season.club_id.to_s + "/" + @new_season.id.to_s)
      else
        if params.fetch("season_title").present?
          flash[:alert] = "Season creation was unsuccessful. Please enter a numerical amount of money for season participants to start with. If you do not want to give participants money yet, please enter 0."
        else
          flash[:alert] = "Season creation was unsuccessful. Please provide a title for your Season."
        end
        redirect_to("/new_season")
      end

    end

  end

  def close_season
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    closed_season = Season.where({ :id => @season_id }).at(0)
    season_markets = closed_season.markets
    markets_not_closed_counter = 0
    
    #Confirm user submitting form is the Season owner
    @owner_user_id = Membership.where({ :season_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).user_id
    
    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/seasons/" + @club_id.to_s + "/"+ @season_id.to_s)
    else
      #check if all markets are closed
      season_markets.each do |market_closed_check|
        if market_closed_check.status != "closed"
          markets_not_closed_counter = markets_not_closed_counter + 1
        end
      end
      
      #check if all markets in season are closed and then close season if so
      if markets_not_closed_counter == 0
        flash[:notice] = "Season was successfully closed!"
        closed_season.status = "closed"
        closed_season.save
      else
        flash[:alert] = "At least one Market in the Season is not yet closed. Please make sure all Markets are closed before closing the Season."
      end
      
      redirect_to("/seasons/" + @club_id.to_s + "/"+ @season_id.to_s)
      
    end
    
  end

  private

  def season_params
    params.permit(:title, :description, :picture, :id, :_method)
  end

  def membership_attributes
    { user_id: current_user.id, goes_to: 'seasons_table', category: 'owner' }
  end


end
