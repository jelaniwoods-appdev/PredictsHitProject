class SeasonController < ApplicationController
  
  def show_seasons
    @membership_rows = Membership.where({ :users_id => current_user.id, :goes_to => "seasons_table" }).order({ :clubs_id => :asc, :seasons_id => :asc })
    render({ :template => "season_templates/show_season_memberships.html.erb" })
  end

  def view_season
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    @club_row = Club.where({ :id => club_id }).at(0)
    @season_row = Season.where({ :id => season_id}).at(0)
    @market_rows = @season_row.markets
    @membership_rows = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table"})
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