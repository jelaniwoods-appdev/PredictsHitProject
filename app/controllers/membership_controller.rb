class MembershipController < ApplicationController

  def add_club_member
    @club_id = params.fetch("club_id")
    @member_username = params.fetch("username")
    @user_row = User.where({ :username => @member_username }).at(0)
    @member_category = params.fetch("member_category")

    if @user_row.present?
 
      @new_membership = Membership.new
      @new_membership.users_id = @user_row.id
      @new_membership.clubs_id = @club_id
      @new_membership.goes_to = "clubs_table"
      @new_membership.category = @member_category
      if @new_membership.valid?
        @new_membership.save
        flash[:notice] = "Club Member was successfully added!" 
      else
        flash[:alert] = "It looks like this user is already a member!" 
      end
    else 
      flash[:alert] = "There was an issue adding this member to your Club. Please confirm you entered the correct username."
    end
    redirect_to("/clubs/" + @club_id.to_s)
  end


  def add_season_member
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @member_id = params.fetch("member_id")
    @member_category = params.fetch("member_category")
    
    #add validation check!?
    
    #Create membership row for added user
    @new_membership = Membership.new
    @new_membership.users_id = @member_id
    @new_membership.clubs_id = @club_id
    @new_membership.seasons_id = @season_id
    @new_membership.goes_to = "seasons_table"
    @new_membership.category = @member_category
    @new_membership.save

    #Add asset row for added user
      #find fund row in season table
      @season_fund = Season.where({ :id => @season_id }).at(0).fund
    
    @new_membership_asset = Asset.new
    @new_membership_asset.membership_id = @new_membership.id
    @new_membership_asset.season_id = @season_id
    @new_membership_asset.category = "season_fund"
    @new_membership_asset.quantity = @season_fund
    @new_membership_asset.save

    flash[:notice] = "Season Member was successfully added!" 

    redirect_to("/seasons/manage/" + @club_id.to_s + "/" + @season_id.to_s)
  end
end