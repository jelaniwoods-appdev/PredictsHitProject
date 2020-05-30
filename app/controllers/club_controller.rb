class ClubController < ApplicationController
  
  def show_clubs
    @membership_rows = Membership.where({ :users_id => current_user.id, :goes_to => "clubs_table" })
    render({ :template => "club_templates/show_club_memberships.html.erb" })
  end

  def view_club

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