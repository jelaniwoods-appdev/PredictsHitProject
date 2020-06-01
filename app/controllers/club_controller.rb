class ClubController < ApplicationController
  
  def show_clubs
    @membership_rows = Membership.where({ :users_id => current_user.id, :goes_to => "clubs_table" }).order({ :id => :desc })
    render({ :template => "club_templates/show_club_memberships.html.erb" })
  end


  def manage_club
    club_id = params.fetch("club_id")
    @club_row = Club.where({ :id => club_id }).at(0)
    @season_rows = Season.where({ :club_id => club_id})
    @membership_rows = Membership.where({ :clubs_id => club_id, :goes_to => "clubs_table"})
    render({ :template => "club_templates/manage_club_page.html.erb" })
  end

  def update_club_details

    @updated_title = params.fetch("updated_club_title")
    @updated_description = params.fetch("updated_club_description")
    @club_id = params.fetch("club_id")
    updated_club_details = Club.where({ :id => @club_id }).at(0)
    updated_club_details.title = @updated_title
    updated_club_details.description = @updated_description
    updated_club_details.save

    flash[:notice] = "Club Details were successfully updated!"
    redirect_to("/clubs/manage/" + @club_id.to_s)
  end

  def view_club
    club_id = params.fetch("club_id")
    @club_row = Club.where({ :id => club_id }).at(0)
    @season_rows = Season.where({ :club_id => club_id}).order({ :id => :desc })
    @membership_rows = Membership.where({ :clubs_id => club_id, :goes_to => "clubs_table"})

    #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners.
    @owner_user_id = Membership.where({ :clubs_id => club_id, :goes_to => "clubs_table", :category => "owner"}).at(0).users_id
    render({ :template => "club_templates/club_details.html.erb" })
  end
  
  def club_create_form
    render({ :template => "club_templates/create_club_page.html.erb" })
  end

  def create_club
    #Create a new club and pass in the form fields
    @new_club = Club.new
    @new_club.title = params.fetch("club_title")
    @new_club.description = params.fetch("club_description")
    @new_club.save
    #Create a new membership to this club and assign the creator of the club to be the 'owner'
    @new_membership = Membership.new
    @new_membership.users_id = current_user.id
    @new_membership.clubs_id = @new_club.id
    @new_membership.goes_to = "clubs_table"
    @new_membership.category = "owner"
    @new_membership.save
    
    redirect_to("/")
  end

end