class AccountController < ApplicationController
  

  def create_account
    @new_account = Account.new
    @new_account.username = params.fetch("new_username")
    @new_account.user_id = params.fetch("user_id")
    @new_account.category = "basic"
    @new_account.save

    redirect_to("/profile")
  end

  def edit_account
    @updated_username = params.fetch("edited_username")
    @updated_prof_pic = params.fetch("edited_prof_pic")
    @account_id = params.fetch("account_id")
    updated_account = Account.where({ :id => @account_id}).at(0)
    updated_account.username = @updated_username
    updated_account.prof_pic = @updated_prof_pic

    updated_account.save

    flash[:notice] = "Your profile was successfully updated!"

    redirect_to("/profile/" + @account_id)
  end

  def show_account
    @account_info = Account.where({ :user_id => current_user.id })
    render({ :template => "account_templates/profile_page.html.erb" })
  end

  def view_user_profile
    @user_profile_id = params.fetch("user_id")
    @account_info = User.where({ :id => @user_profile_id }).at(0)
    render({ :template => "account_templates/view_user_profile.html.erb" })
  end


end