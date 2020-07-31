class AssetController < ApplicationController
  
  def update_season_funds
    #update fund field in seasons table. This will keep track of total funds added and will make it so participants added in future will get these extra funds included when they join
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    
    #confirm season owner is the one submitting this form
    @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id


    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/seasons/" + @club_id.to_s + "/"+ @season_id.to_s)
    else

      if params.fetch("amount_added").numeric?
        @fund_change_amount = params.fetch("amount_added").to_f

        season_to_change = Season.where({ :id => @season_id }).at(0)
        season_to_change.fund = season_to_change.fund + @fund_change_amount
        if season_to_change.valid?
          season_to_change.save

          #update assets table such that current users have updated funds
          @asset_rows = Asset.where({ :season_id => @season_id, :category => "season_fund"})
          @asset_rows.each do |add_funds|
            add_funds.quantity = add_funds.quantity + @fund_change_amount
            add_funds.save
          end
          
          if @fund_change_amount < 0
            flash[:notice] = ActiveSupport::NumberHelper.number_to_currency(@fund_change_amount) + " in funds were successfully removed from all Season users!"
          else
            flash[:notice] = ActiveSupport::NumberHelper.number_to_currency(@fund_change_amount) + " in funds were successfully added to all Season users!"
          end
          
          redirect_to("/seasons/" + @club_id.to_s + "/"+ @season_id.to_s)

        else

          flash[:alert] = "Fund change was unsuccessful. Please enter a valid number."
          redirect_to("/seasons/" + @club_id.to_s + "/"+ @season_id.to_s)
        end
      else
        flash[:alert] = "Fund change was unsuccessful. Please enter a valid number."
        redirect_to("/seasons/" + @club_id.to_s + "/"+ @season_id.to_s)
      end
    end

  end

  def adjust_user_season_funds
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @user_id = params.fetch("user_id")
    @user_funds_entered = params.fetch("fund_amount").to_f
    @adjustment_factor = params.fetch("adjustment_factor")

    @username = User.where({ :id => @user_id }).at(0).username
    @membership_id = Membership.where({ :users_id => @user_id, :seasons_id => @season_id, :goes_to => "seasons_table"}).at(0).id
    @asset_row = Asset.where({ :membership_id => @membership_id, :category => "season_fund"}).at(0)
    
    #confirm season owner is the one submitting this form
    @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/seasons/" + @club_id.to_s + "/"+ @season_id.to_s)
    else
      #if adjustment_factor is positive, fund amount changed is same as entered, if negative, then multiply by -1
      if @adjustment_factor == "positive"
        @user_funds_changed = @user_funds_entered
      elsif @adjustment_factor == "negative"
        @user_funds_changed = @user_funds_entered * -1
      else
        flash[:alert] = "User fund not updated. Please enter a valid number."
        redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id.to_s)
      return
      end

      @asset_row.quantity = @asset_row.quantity + @user_funds_changed
      @asset_row.save

      if @user_funds_changed > 0
        flash[:notice] = ActiveSupport::NumberHelper.number_to_currency(@user_funds_entered) + " has successfully been added to " + @username + "'s season fund!"
      else
        flash[:notice] = ActiveSupport::NumberHelper.number_to_currency(@user_funds_entered) + " has successfully been removed from " + @username + "'s season fund!"
      end
      
      redirect_to("/seasons/" + @club_id.to_s + "/" + @season_id.to_s)

    end

  end
  
end



    