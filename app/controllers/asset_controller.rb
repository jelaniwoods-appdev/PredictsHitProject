class AssetController < ApplicationController
  def update_season_funds
    #update fund field in seasons table. This will keep track of total funds added and will make it so participants added in future will get these extra funds included when they join
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @fund_change_amount = params.fetch("amount_added").to_f

    season_to_change = Season.where({ :id => @season_id }).at(0)
    season_to_change.fund = season_to_change.fund + @fund_change_amount
    season_to_change.save

    #update assets table such that current users have updated funds
    @asset_rows = Asset.where({ :season_id => @season_id, :category => "season_fund"})
    @asset_rows.each do |add_funds|
      add_funds.quantity = add_funds.quantity + @fund_change_amount
      add_funds.save
    end

    flash[:notice] = "Funds were successfully added to season users!"
    redirect_to("/seasons/manage/" + @club_id.to_s + "/"+ @season_id.to_s)

  end
end



    