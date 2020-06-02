class SeasonController < ApplicationController
  
  def show_seasons
    @membership_rows = Membership.where({ :users_id => current_user.id, :goes_to => "seasons_table" }).order({ :clubs_id => :asc, :seasons_id => :asc })
    render({ :template => "season_templates/show_season_memberships.html.erb" })
  end

  def manage_season
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    @club_row = Club.where({ :id => club_id }).at(0)
    @season_row = Season.where({ :id => season_id }).at(0)
    @membership_rows = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table"})
    render({ :template => "season_templates/manage_season_page.html.erb" })
  end

  def update_season_details
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @updated_title = params.fetch("updated_season_title")
    @updated_description = params.fetch("updated_season_description")
  
    updated_season_details = Season.where({ :id => @season_id }).at(0)
    updated_season_details.title = @updated_title
    updated_season_details.description = @updated_description
    updated_season_details.save

    flash[:notice] = "Season Details were successfully updated!"
    redirect_to("/seasons/manage/" + @club_id.to_s + "/"+ @season_id.to_s)
  end

  def view_season
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    @club_row = Club.where({ :id => club_id }).at(0)
    @season_row = Season.where({ :id => season_id}).at(0)
    @market_rows = @season_row.markets
    @membership_rows = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table"})

    #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners.
    @owner_user_id = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id
    render({ :template => "season_templates/season_details.html.erb" })
  end
  
  def season_create_form
    render({ :template => "season_templates/create_season_page.html.erb" })
  end

  def create_season
    #Create a new season and pass in the form fields
    @new_season = Season.new
    @new_season.club_id = params.fetch("associated_club_id")
    @new_season.title = params.fetch("season_title")
    @new_season.description = params.fetch("season_description")
    @new_season.status = "active"
    @new_season.save
    #Create a new membership to this season and assign the creator of the season to be the 'owner'
    @new_membership = Membership.new
    @new_membership.users_id = current_user.id
    @new_membership.seasons_id = @new_season.id
    @new_membership.clubs_id = params.fetch("associated_club_id")
    @new_membership.goes_to = "seasons_table"
    @new_membership.category = "owner"
    @new_membership.save
    
    redirect_to("/")
  end

end