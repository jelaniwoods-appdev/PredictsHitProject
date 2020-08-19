class ClubsController < ApplicationController

  def index
    @memberships = current_user.memberships.where(goes_to: 'clubs_table').order(id: :desc)
  end


  def update
    # does not handle case where club_id is not valid
   
    @club = Club.find(params[:id])
    @club.assign_attributes(club_params.slice(:title, :description, :picture))

    #confirm club owner is the one submitting this form
    if !@club.memberships.where(category: 'owner', user_id: current_user.id).exists?
      flash[:alert] = "You are not authorized to perform this action."
    else
      if @club.save
        flash[:notice] = "Club details were successfully updated!"
      else
        flash[:alert] = "Club details were not updated. Please include a title."
      end
    end

    redirect_to("/clubs/" + @club.id.to_s)
  end

  def show
    @club = Club.find(params[:id])
    @current_seasons = @club.seasons.open.order(id: :desc)
    @closed_seasons = @club.seasons.closed.order(id: :desc)
    @memberships = @club.memberships.order_as_specified(category: %w[owner admin member])

    #relevant comments
    @club_messages_all = @club.chats.order(created_at: :desc)
    @club_messages_latest = @club_messages_all.first(50).reverse

    if @memberships.where(user_id: current_user.id).empty?
      flash[:alert] = "You are not authorized to view this page."
      redirect_to root_path
    else
      #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners.
      @owner_user_id = @memberships.where(category: "owner").first.try(:user_id)
    end
  end

  def new
  end

  def create
    #Create a new club and pass in the form fields
    @new_club = Club.new(club_params)

    @membership = @new_club.memberships.build(membership_attributes)
    # `save` will run validations and return true or false if the record has
    # persisted or not.
    # This will also use a SQL transaction to save both the club and the membership at the same time.
    # If either fails to persist, neither will persist.
    if @new_club.save
      flash[:notice] = "Your club has been successfully created!"
      redirect_to club_path(@new_club)
    else
      flash[:alert] = "Club creation was unsuccessful. Please enter a title."

      render :new
    end
  end

  private

  def club_params
    params.permit(:title, :description, :picture, :id, :_method)
  end

  def membership_attributes
    { user_id: current_user.id, goes_to: 'clubs_table', category: 'owner' }
  end

end
