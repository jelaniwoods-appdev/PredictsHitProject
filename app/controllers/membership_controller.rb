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

  def manage_club_members
    @club_id = params.fetch("club_id")
    @member_user_id = params.fetch("user_id")
    @user_row = User.where({ :id => @member_user_id }).at(0)
    @membership_row = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :users_id => @member_user_id }).at(0)
    @owner_membership_row = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :category => "owner" }).at(0)
    @member_category = params.fetch("member_category")

    if @member_category == @membership_row.category
      flash[:alert] = @user_row.username.to_s + " was already a " + @member_category.to_s + "."
      redirect_to("/clubs/" + @club_id.to_s)
    else
      if @member_category == "owner"
        #if changing owner status, remove current owner and change to admin and then update user to owner
        @owner_membership_row.category = "admin"
        @owner_membership_row.save
        @membership_row.category = @member_category
        @membership_row.save

        flash[:notice] = @user_row.username.to_s + " is now the " + @member_category.to_s + "."

        redirect_to("/clubs/" + @club_id.to_s)
      else
        #do not allow owner to change themselves to admin or member
        if @membership_row.category == "owner"
          flash[:alert] = "You cannot remove yourself as owner without assigning someone else. If you no longer want to be the owner, assign someone else to be the owner."
          redirect_to("/clubs/" + @club_id.to_s)
        else
          @membership_row.category = @member_category
          @membership_row.save
          
          flash[:notice] = @user_row.username.to_s + " is now a " + @member_category.to_s + "."

          redirect_to("/clubs/" + @club_id.to_s)
        end
      end
    end
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

    redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id.to_s)
  end

    def manage_season_members
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @member_user_id = params.fetch("user_id")
    @user_row = User.where({ :id => @member_user_id }).at(0)
    @membership_row = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :users_id => @member_user_id }).at(0)
    @owner_membership_row = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner" }).at(0)
    @member_category = params.fetch("member_category")

    if @member_category == @membership_row.category
      flash[:alert] = @user_row.username.to_s + " was already a " + @member_category.to_s + "."
      redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id.to_s)
    else
      if @member_category == "owner"
        #if changing owner status, remove current owner and change to admin and then update user to owner
        @owner_membership_row.category = "admin"
        @owner_membership_row.save
        @membership_row.category = @member_category
        @membership_row.save

        flash[:notice] = @user_row.username.to_s + " is now the " + @member_category.to_s + "."

        redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id.to_s)
      else
        #do not allow owner to change themselves to admin or member
        if @membership_row.category == "owner"
          flash[:alert] = "You cannot remove yourself as owner without assigning someone else. If you no longer want to be the owner, assign someone else to be the owner."
          redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id.to_s)
        else
          @membership_row.category = @member_category
          @membership_row.save
          
          flash[:notice] = @user_row.username.to_s + " is now a " + @member_category.to_s + "."

          redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id.to_s)
        end
      end
    end
  end


  def add_market_member
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
    @member_username = params.fetch("username")
    @user_row = User.where({ :username => @member_username }).at(0)
    
    #add validation check!?
    
    #Create club membership row for added user
    if @user_row.present?

      @new_club_membership = Membership.new
      @new_club_membership.users_id = @user_row.id
      @new_club_membership.clubs_id = @club_id
      @new_club_membership.goes_to = "clubs_table"
      @new_club_membership.category = "member"
      if @new_club_membership.valid?
        @new_club_membership.save
      end

      #Create season membership row for added user
      @new_season_membership = Membership.new
      @new_season_membership.users_id = @user_row.id
      @new_season_membership.clubs_id = @club_id
      @new_season_membership.seasons_id = @season_id
      @new_season_membership.goes_to = "seasons_table"
      @new_season_membership.category = "member"
      if @new_season_membership.valid?
        @new_season_membership.save

        #Add asset row for added user
          #find fund row in season table
          @season_fund = Season.where({ :id => @season_id }).at(0).fund
        
        @new_season_membership_asset = Asset.new
        @new_season_membership_asset.membership_id = @new_season_membership.id
        @new_season_membership_asset.season_id = @season_id
        @new_season_membership_asset.category = "season_fund"
        @new_season_membership_asset.quantity = @season_fund
        @new_season_membership_asset.save

        flash[:notice] = "Player was successfully added!" 

        redirect_to("/markets/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s)

      else
        flash[:alert] = "There was an issue adding this player. It looks like the player has already been invited!" 

        redirect_to("/markets/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s)
      end
      
    else 
      flash[:alert] = "There was an issue adding this player. Please confirm you entered the correct username."
      redirect_to("/markets/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s)
    end

  end

end