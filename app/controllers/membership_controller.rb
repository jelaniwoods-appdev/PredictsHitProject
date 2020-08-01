class MembershipController < ApplicationController

  def add_club_member
    @club_id = params.fetch("club_id")
    @member_username = params.fetch("username")
    @user_row = User.where("lower(username) = ?", @member_username.downcase).at(0)
    @member_category = params.fetch("member_category")

    #confirm user submitting form is the club owner
    @owner_user_id = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :category => "owner"}).at(0).users_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/clubs/" + @club_id.to_s)
    else
        
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

  end

  def manage_club_members
    @club_id = params.fetch("club_id")
    @member_user_id = params.fetch("user_id")
    @user_row = User.where({ :id => @member_user_id }).at(0)
    @membership_row = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :users_id => @member_user_id }).at(0)
    @owner_membership_row = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :category => "owner" }).at(0)
    @owner_user_id = @owner_membership_row.users_id
    @member_category = params.fetch("member_category")

    #confirm user submitting form is the club owner
    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/clubs/" + @club_id.to_s)
    else

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

  end

  def leave_club
    @club_id = params.fetch("club_id")
    @user_club_membership_row = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :users_id => current_user.id }).at(0)
    @user_season_membership_rows = Membership.where({ :clubs_id => @club_id, :goes_to => "seasons_table", :users_id => current_user.id })
    @club_membership_rows = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table"})
    @owner_membership_row = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :category => "owner" }).at(0)
    @member_category = @user_club_membership_row.category

    if @member_category == "owner" && @club_membership_rows.count > 1
      flash[:alert] = "You are the Club owner. You'll have to assign someone else to be the owner before you can leave."
      redirect_to("/clubs/" + @club_id.to_s)
    else
      #remove user club membership
      @user_club_membership_row.destroy

      #go through each season membership in that club and destroy user's membership. If they are a season owner and there is at least one other person in the season, assign someone else to become the owner
      @user_season_membership_rows.each do |season_membership|
        if season_membership.category == "owner"
          #find other season memberships and first pick among admins if there are any (category desc), and then based on who has the oldest membership
          new_owner = Membership.where({ :seasons_id => season_membership.seasons_id, :goes_to => "seasons_table" }).where.not({ :users_id => current_user.id }).order({ :category => :asc, :created_at => :asc }).at(0)
          #if someone else is present in a season where user leaving club is the owner, then assign new owner, otherwise just have them leave the season since no one needs to be the owner
          if new_owner.present?
            new_owner.category = "owner"
            new_owner.save
          end
          
          season_membership.destroy

        else
          season_membership.destroy
        end
      end

      flash[:notice] = "You have successfully left the Club and any associated Seasons."

      redirect_to("/")
    end
  end


  def add_season_member
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @member_id = params.fetch("member_id")
    @member_category = params.fetch("member_category")
    
    #confirm user submitting form is the season owner
    @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id
    
    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id.to_s)
    else
    
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

  end

    def manage_season_members
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @member_user_id = params.fetch("user_id")
    @user_row = User.where({ :id => @member_user_id }).at(0)
    @membership_row = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :users_id => @member_user_id }).at(0)
    @owner_membership_row = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner" }).at(0)
    @owner_user_id = @owner_membership_row.users_id
    @member_category = params.fetch("member_category")

    #confirm user submitting form is the season owner
    
    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id.to_s)
    else

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

  end

  def leave_season
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @user_season_membership_row = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :users_id => current_user.id }).at(0)
    @season_membership_rows = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table"})
    @member_category = @user_season_membership_row.category

    if @member_category == "owner" && @season_membership_rows.count > 1
      flash[:alert] = "You are the Season owner. You'll have to assign someone else to be the owner before you can leave."
      redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id)
    else
      #remove user club membership
      @user_season_membership_row.destroy

      flash[:notice] = "You have successfully left the Season."

      redirect_to("/clubs/" + @club_id.to_s)
    end
  end



  def add_market_member
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
    @member_username = params.fetch("username")
    @user_row = User.where("lower(username) = ?", @member_username.downcase).at(0)
    
    #confirm user submitting form is both the season owner and the club owner
    @club_owner_user_id = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :category => "owner"}).at(0).users_id
    @season_owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id
    
    if (@club_owner_user_id != current_user.id) || (@season_owner_user_id != current_user.id)
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/markets/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s)
    else

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

end