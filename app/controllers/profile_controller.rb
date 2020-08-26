class ProfileController < ApplicationController
  
  def update_profile
    @updated_username = params.fetch("updated_username")
    @user_id = params.fetch("user_id")

    #confirm user submitting form is the user whose profile is being updated
    if @user_id != current_user.id.to_s
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/")
    else
      updated_profile = User.where({ :id => @user_id}).at(0)
      updated_profile.username = @updated_username
      if params[:prof_pic].present?
        updated_profile.prof_pic = params.fetch("prof_pic")
      end
      if updated_profile.valid?
        updated_profile.save
        redirect_to("/profile/manage/" + @user_id, { :notice => "Your profile was successfully updated!"})
      else
        redirect_to("/profile/manage/" + @user_id, { :alert => "Your profile was not updated."})
      end

    end

  end

  def show_profile
    @user_id = params.fetch("user_id")
    @profile_info = User.where({ :id => @user_id }).at(0)
    render({ :template => "profile_templates/profile_page.html.erb" })
  end

  def manage_profile_page
    @user_id = params.fetch("user_id")
    
    if @user_id != current_user.id.to_s
      flash[:alert] = "You are not authorized to view this page."
      redirect_to("/")
    else
      @profile_info = User.where({ :id => @user_id }).at(0)
      render({ :template => "profile_templates/edit_profile_page.html.erb" })
    end
  end

end