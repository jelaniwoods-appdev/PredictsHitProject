class SeasonController < ApplicationController
  
  def show_seasons
    @membership_rows = Membership.where({ :users_id => current_user.id, :goes_to => "seasons_table" }).order({ :clubs_id => :asc, :seasons_id => :asc })
    render({ :template => "season_templates/show_season_memberships.html.erb" })
  end

  def update_season_details
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @updated_title = params.fetch("updated_season_title")
    @updated_description = params.fetch("updated_season_description")
  
    updated_season_details = Season.where({ :id => @season_id }).at(0)
    updated_season_details.title = @updated_title
    updated_season_details.description = @updated_description
    if params[:updated_season_picture].present?
      updated_season_details.picture = params.fetch("updated_season_picture")
    end
    updated_season_details.save

    flash[:notice] = "Season Details were successfully updated!"
    redirect_to("/seasons/" + @club_id.to_s + "/"+ @season_id.to_s)
  end

  def view_season
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    @club_row = Club.where({ :id => club_id }).at(0)
    @season_row = Season.where({ :id => season_id}).at(0)
    @current_market_rows = @season_row.markets.where.not({ :status => "closed" })
    @closed_market_rows = @season_row.markets.where({ :status => "closed" })
    @season_membership_rows = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table"})
    @club_membership_rows = Membership.where({ :clubs_id => club_id, :goes_to => "clubs_table"})

    #relevant comments
    @season_comments = Comment.where({ :seasons_id => season_id, :goes_to => "season" }).hash_tree
    @season_messages = Chat.where({ :seasons_id => season_id, :goes_to => "season" }).order({ :created_at => :desc })

    if @season_membership_rows.where({ :users_id => current_user.id}).empty?
      flash[:alert] = "You are not authorized to view this page."
      redirect_to("/")
    else
      #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners.
      @owner_user_id = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id
      render({ :template => "season_templates/season_details.html.erb" })
    end
  end
  
  def season_create_form
    @user_id = current_user.id

    #pull the club memberships in which the user is an owner or admin for
    #see if better way to map memberships to clubs
    #later make it so only active clubs show up and/or include search option.
    @user_club_memberships = Membership.where({ :users_id => @user_id, :goes_to => "clubs_table", :category => "owner"}).or(Membership.where({ :users_id => @user_id, :goes_to => "clubs_table", :category => "admin"}))
    
    render({ :template => "season_templates/create_season_page.html.erb" })
  end

  def create_season
    #Create a new season and pass in the form fields
    @new_season = Season.new
    @new_season.club_id = params.fetch("associated_club_id")
    @new_season.title = params.fetch("season_title")
    @new_season.description = params.fetch("season_description")
    @new_season.fund = params.fetch("season_fund")
    @new_season.status = "active"
    if params[:season_picture].present?
      @new_season.picture = params.fetch("season_picture")
    end
    if @new_season.valid?
      @new_season.save
      #Create a new membership to this season and assign the creator of the season to be the 'owner'
      @new_membership = Membership.new
      @new_membership.users_id = current_user.id
      @new_membership.seasons_id = @new_season.id
      @new_membership.clubs_id = params.fetch("associated_club_id")
      @new_membership.goes_to = "seasons_table"
      @new_membership.category = "owner"
      @new_membership.save
      
      #Create a new asset associated to this membership based on funding amount
      @new_asset = Asset.new
      @new_asset.membership_id = @new_membership.id
      @new_asset.season_id = @new_season.id
      @new_asset.category = "season_fund"
      @new_asset.quantity = params.fetch("season_fund")
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

  def close_season
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    closed_season = Season.where({ :id => @season_id }).at(0)
    season_markets = closed_season.markets
    markets_not_closed_counter = 0
    
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