class ClubController < ApplicationController
  
  def show_clubs
    @membership_rows = Membership.where({ :users_id => current_user.id, :goes_to => "clubs_table" }).order({ :id => :desc })
    render({ :template => "club_templates/show_club_memberships.html.erb" })
  end


  def update_club_details
    @updated_title = params.fetch("updated_club_title")
    @updated_description = params.fetch("updated_club_description")
    @club_id = params.fetch("club_id")

    #confirm club owner is the one submitting this form
    @owner_user_id = Membership.where({ :clubs_id => @club_id, :goes_to => "clubs_table", :category => "owner"}).at(0).users_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/clubs/" + @club_id.to_s)
    else
      updated_club_details = Club.where({ :id => @club_id }).at(0)
      updated_club_details.title = @updated_title
      updated_club_details.description = @updated_description
      if params[:updated_club_picture].present?
        updated_club_details.picture = params.fetch("updated_club_picture")
      end
      if updated_club_details.valid?
        updated_club_details.save
        flash[:notice] = "Club details were successfully updated!"
        redirect_to("/clubs/" + @club_id.to_s)
      else
        flash[:alert] = "Club details were not updated. Please include a title."
        redirect_to("/clubs/" + @club_id.to_s)
      end
    end
  end

  def view_club
    
    club_id = params.fetch("club_id")
    @club_row = Club.where({ :id => club_id }).at(0)
    @current_season_rows = Season.where({ :club_id => club_id}).where.not({ :status => "closed" }).order({ :id => :desc })
    @closed_season_rows = Season.where({ :club_id => club_id}).where({ :status => "closed" }).order({ :id => :desc })
    @membership_rows = Membership.where({ :clubs_id => club_id, :goes_to => "clubs_table"}).order_as_specified(category: ["owner", "admin", "member"])

    #relevant comments
    @club_messages_all = Chat.where({ :clubs_id => club_id, :goes_to => "club" }).order({ :created_at => :desc })
    @club_messages_latest = @club_messages_all.first(50).reverse

    if @membership_rows.where({ :users_id => current_user.id}).empty?
      flash[:alert] = "You are not authorized to view this page."
      redirect_to("/")
    else
      #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners.
      @owner_user_id = Membership.where({ :clubs_id => club_id, :goes_to => "clubs_table", :category => "owner"}).at(0).users_id
      render({ :template => "club_templates/club_details.html.erb" })
    end
  end
  
  def club_create_form
    render({ :template => "club_templates/create_club_page.html.erb" })
  end

  def create_club
    #Create a new club and pass in the form fields
    @new_club = Club.new
    @new_club.title = params.fetch("club_title")
    @new_club.description = params.fetch("club_description")
    if params[:club_picture].present?
      @new_club.picture = params.fetch("club_picture")
    end
    if @new_club.valid?
      @new_club.save
      #Create a new membership to this club and assign the creator of the club to be the 'owner'
      @new_membership = Membership.new
      @new_membership.users_id = current_user.id
      @new_membership.clubs_id = @new_club.id
      @new_membership.goes_to = "clubs_table"
      @new_membership.category = "owner"
      @new_membership.save
      
      flash[:notice] = "Club successfully created!" 
      redirect_to("/clubs/" + @new_club.id.to_s)
    else
      flash[:alert] = "Club creation was unsuccessful. Please enter a title." 
      redirect_to("/new_club")
    end
  end

end
