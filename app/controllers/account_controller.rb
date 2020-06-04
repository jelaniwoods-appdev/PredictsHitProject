class AccountController < ApplicationController
  
  def update_account
    @updated_username = params.fetch("updated_username")
    @account_id = params.fetch("account_id")
    updated_account = User.where({ :id => @account_id}).at(0)
    updated_account.username = @updated_username
    if updated_account.valid?
      updated_account.save
      redirect_to("/account/manage/" + @account_id, { :notice => "Your profile was successfully updated!"})
    else
      redirect_to("/account/manage/" + @account_id, { :alert => "Your profile was not updated. Username invalid or already taken."}) #Will need to update to make more clear and be dynamic for issue once other options to change/other failure points.
    end
  end

  def show_account
    @account_id = params.fetch("user_id")
    @account_info = User.where({ :id => @account_id }).at(0)
    render({ :template => "account_templates/profile_page.html.erb" })
  end

  def manage_account_page
    @account_id = params.fetch("user_id")
    @account_info = User.where({ :id => @account_id }).at(0)
    render({ :template => "account_templates/edit_profile_page.html.erb" })
  end


end