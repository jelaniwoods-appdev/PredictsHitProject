class MembershipController < ApplicationController

  def add_club_member
    @club_id = params.fetch("club_id")
    @member_id = params.fetch("member_id")
    @member_category = params.fetch("member_category")
    
    @new_membership = Membership.new
    @new_membership.users_id = @member_id
    @new_membership.clubs_id = @club_id
    @new_membership.goes_to = "clubs_table"
    @new_membership.category = @member_category
    @new_membership.save

    flash[:notice] = "Club Member was successfully added!" 

    redirect_to("/clubs/manage/" + @club_id.to_s)
  end

end