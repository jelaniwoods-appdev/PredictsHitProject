class ContractController < ApplicationController
  include ActionView::Helpers::NumberHelper

  def add_contract
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")

    #confirm season owner is the one submitting this form
    @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/markets/" + @club_id + "/" + @season_id + "/" + @market_id)
    else
      @new_contract = Contract.new
      @new_contract.market_id = @market_id
      @new_contract.title =  params.fetch("contract_title")
      @new_contract.description = params.fetch("contract_description")
      @new_contract.quantity_a = 0
      @new_contract.quantity_b = 0
      @new_contract.category = @new_contract.market.category
      @new_contract.status = "active"
      if params[:contract_picture].present?
        @new_contract.contractpic = params.fetch("contract_picture")
      end
      
      
      if @new_contract.valid?
        @new_contract.save
        flash[:notice] = "Contract successfully created!" 
        redirect_to("/markets/" + @club_id + "/" + @season_id + "/" + @market_id)
      else
        flash[:alert] = "Contract creation was unsuccessful. Please enter a title."
        redirect_to("/markets/" + @club_id + "/" + @season_id + "/" + @market_id)
      end
    end

  end

  def manage_contract
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    market_id = params.fetch("market_id")
    contract_id = params.fetch("contract_id")

    @club_row = Club.where({ :id => club_id }).at(0)
    @season_row = Season.where({ :id => season_id }).at(0)
    @market_row = Market.where({ :id => market_id }).at(0)
    @contract_row = Contract.where({ :id => contract_id }).at(0)
    @membership_rows = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table"})
    #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners.
    @owner_user_id = Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to view this page."
      redirect_to("/")
    else
      render({ :template => "contract_templates/manage_contract_page.html.erb" })
    end
    
  end


  def view_contract
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
    @contract_id = params.fetch("contract_id")

    @club_row = Club.where({ :id => @club_id }).at(0)
    @season_row = Season.where({ :id => @season_id}).at(0)
    @market_row = Market.where({ :id => @market_id}).at(0)
    @contract_row = Contract.where({ :id => @contract_id}).at(0)
    @membership_rows = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table"})

    

    if @membership_rows.where({ :users_id => current_user.id}).empty?
      flash[:alert] = "You are not authorized to view this page."
      redirect_to("/")
    else
      #determine owner and/or admins. Do single owner for now but later add admin info and potentially allow for multiple owners. Note: this is based on season ownership as there is no special ownership of markets/contracts.
      @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

      render({ :template => "contract_templates/contract_details.html.erb" })
    end

  end

  def update_contract_details
    @club_id = params.fetch("club_id")
    @season_id = params.fetch("season_id")
    @market_id = params.fetch("market_id")
    @contract_id = params.fetch("contract_id")
    @updated_title = params.fetch("updated_contract_title")
    @updated_description = params.fetch("updated_contract_description")
  
    #confirm season owner is the one submitting this form
    @owner_user_id = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table", :category => "owner"}).at(0).users_id

    if @owner_user_id != current_user.id
      flash[:alert] = "You are not authorized to perform this action."
      redirect_to("/contracts/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s + "/" + @contract_id.to_s)
    else
      updated_contract_details = Contract.where({ :id => @contract_id }).at(0)
      updated_contract_details.title = @updated_title
      updated_contract_details.description = @updated_description
      if params[:updated_contract_picture].present?
        updated_contract_details.contractpic = params.fetch("updated_contract_picture")
      end

      if updated_contract_details.valid?
        
        updated_contract_details.save

        flash[:notice] = "Contract details were successfully updated!"
        redirect_to("/contracts/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s + "/" + @contract_id.to_s)
      else
        flash[:alert] = "Contract details were not updated. Please include a title."
        redirect_to("/contracts/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s + "/" + @contract_id.to_s)
      end
    end

  end

  #buy/sell contracts 
  #later update so the buy/sell/yes/no are separate controllers which inherit from one?

  def buy_yes_contracts
    #set variables
    @contract_id = params.fetch("contract_id")
    @contract_row = Contract.where({ :id => @contract_id }).at(0)
    @market_id = @contract_row.market.id
    @season_id = @contract_row.market.season.id
    @club_id = @contract_row.market.season.club.id
    
    @number_of_contracts = params.fetch("quantity_buy_yes")
    @membership_row = Membership.where({ :users_id => current_user.id, :seasons_id => @season_id, :goes_to => "seasons_table"}).at(0)
    @user_asset_rows = @membership_row.assets
    @user_season_funds_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :category => "season_fund"}).at(0)
    @user_starting_season_funds = @user_season_funds_row.quantity
    @starting_contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity_a"}).at(0) #membership_row.id is probably unnecessary.

    #confirm user actually belongs to the Season associated with this Contract/Market
    if @membership_row.present?
            
      #Confirm number is a positive integer.
      if @number_of_contracts.to_i < 1 || @number_of_contracts.include?(".")
        flash[:alert] = "There was an error processing your request."
      else
        #check if user already has an asset row associated with this contract (contract id matches and category is "contract_quantity_a").
        #If user does, skip step, otherwise, if user does not, create a new asset with a quantity of 0.
        if @starting_contract_asset_row.present?
        else
          new_asset = Asset.new
          new_asset.membership_id = @membership_row.id
          new_asset.season_id = @season_id
          new_asset.contract_id = @contract_id
          new_asset.category = "contract_quantity_a"
          new_asset.quantity = 0
          new_asset.save
        end

        #add variable to track contract_asset_row now that we know it must exist:
        @contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity_a"}).at(0) #membership_row.id is probably unnecessary.
        
        #algorithm (C= b * ln(e^(q1/b) + e^(q2/b)...))
        #consider updating contract table to include column for quantity outstanding to avoid many of these calculations
        liquidity_param = 50 #set liquidity parameter (b) for now. Later might allow custommization or make b variable.

        #calculate price/cost by running price_check algo
        total_cost = @contract_row.price_check(@contract_id, liquidity_param, @number_of_contracts, "yes")

        if total_cost > @user_season_funds_row.quantity
          flash[:alert] = "Insufficient funds. Sell some contracts or request more funds from the Season owner."
        else
        
        
          #(1) remove accumulated funds from user's season_funds, (2) add contract asset (3) later, make it so this is reflected in transaction table(probably in a first step and base everything off transaction)
          #Update tables based on actions above.

          # remove accumulated funds from user's season_funds. Consider updating method to be based on subtraction from current amount instead of current way.
          @user_season_funds_row.quantity = @user_season_funds_row.quantity - total_cost
          @user_season_funds_row.save

          #update contract quantity in assets table to reflect new purchase
          @contract_asset_row.quantity = @contract_asset_row.quantity + @number_of_contracts.to_i
          @contract_asset_row.save

          #update contract quantity in contracts table to reflect new outstanding balance
          @contract_row.quantity_a = @contract_row.quantity_a + @number_of_contracts.to_i
          @contract_row.save

          if @number_of_contracts.to_i == 1
            flash[:notice] = "Yay! " + @number_of_contracts.to_s + " yes contract was sucessfully purchased for " + number_to_currency(total_cost) + "."
          else
            flash[:notice] = "Yay! " + @number_of_contracts.to_s + " yes contracts were sucessfully purchased for " + number_to_currency(total_cost) + "."
          end
          

        end
      end

        #add instance variables needed for partials that are refreshed
        @contract_rows = @contract_row.market.contracts.order({ :created_at => :asc })
        @membership_id = @membership_row.id
        @season_membership_rows = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table"})
        @market_row = @contract_row.market

        

        respond_to do |format|
          format.js { render 'contract_templates/render_contracts.js.erb' }
        end

    else
      flash[:alert] = "You are not authorized to perform this action."
    end


    #old algorithm
    #contract_id_looper = @contract_row.market.contracts.at(0).id
    #tester = Asset.where({ :contract_id => contract_id_looper }).sum(:quantity)
    
    # #set trackers and counters
    # asset_quantity_counter = 0
    # asset_remaining_tracker = @number_of_contracts.to_i
    # looper = asset_remaining_tracker
    # funds_remaining_tracker = @user_starting_season_funds
    # asset_price_tracker = @starting_contract_price

    # #check if user has sufficient funds to buy one contract. If not, return them to the screen and alert them of insufficient funds.
    # if @user_starting_season_funds < @starting_contract_price
    #   flash[:alert] = "Insufficient funds. Sell some assets or request more money from Season owner."
    #   redirect_to("/markets/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s)
    #   return
    # else
    #   while looper > 0 
    #     if funds_remaining_tracker > asset_price_tracker
          
    #       #reduce season funds by amount of current contract price
    #       funds_remaining_tracker = funds_remaining_tracker - asset_price_tracker

    #       #update asset quantity counter to reflect number of assets accumulated
    #       asset_quantity_counter = asset_quantity_counter + 1

    #       #update contract price based on algorithm. Start with simple algorithm that only adds 0.005 to contract price each time one is purchased.
    #       if asset_price_tracker < 1.000
    #         asset_price_tracker = asset_price_tracker + 0.005
    #       end

    #       #update asset_remaining_tracker to reflect number of assets remaining to be fufilled
    #       asset_remaining_tracker = asset_remaining_tracker - 1

    #     end

    #     #update looper to remove one loop count
    #     looper = looper - 1

    #   end

    # end

    # #(1) remove accumulated funds from user's season_funds, (2) add contract asset, (3) update contract price based on algorithm, (4)later, make it so this is reflected in transaction table(probably in a first step and base everything off transaction)
    #   #Update tables based on actions above.

    #   #remove accumulated funds from user's season_funds. Consider updating method to be based on subtraction from current amount instead of current way.
    #   @user_season_funds_row.quantity = funds_remaining_tracker
    #   @user_season_funds_row.save

    #   #update contract quantity in assets table to reflect new purchase
    #   @contract_asset_row.quantity = @contract_asset_row.quantity + asset_quantity_counter
    #   @contract_asset_row.save
        
    #   #update overall contract quantity in contract table
    #   #update contract price based on accumulated new price based on current algo.
    #   #Consider issues with multiple purchases in quick sucession. Better/safer way to do this?
    #   @contract_row.price = asset_price_tracker
    #   @contract_row.save

    # if asset_remaining_tracker == 0
    #   flash[:notice] = "Yay! All " + asset_quantity_counter.to_s + " contract(s) were sucessfully purchased!" + " Test parameter pre: " + tester_pre.to_s + " Test parameter post: " + tester_post.to_s
    # else
    #   flash[:notice] = "Your order has partially completed. You only had sufficient funds to purchase " + asset_quantity_counter.to_s + " contract(s)."
    # end

  end

  

  def sell_yes_contracts
    #set variables
    @contract_id = params.fetch("contract_id")
    @contract_row = Contract.where({ :id => @contract_id }).at(0)
    @market_id = @contract_row.market.id
    @season_id = @contract_row.market.season.id
    @club_id = @contract_row.market.season.club.id
    
    @number_of_contracts = (params.fetch("quantity_sell_yes").to_i * -1).to_s
    @pos_num_contracts = @number_of_contracts.to_i * -1
    @membership_row = Membership.where({ :users_id => current_user.id, :seasons_id => @season_id, :goes_to => "seasons_table"}).at(0)
    @user_asset_rows = @membership_row.assets
    @user_season_funds_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :category => "season_fund"}).at(0)
    @user_starting_season_funds = @user_season_funds_row.quantity
    @starting_contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity_a"}).at(0) #membership_row.id is probably unnecessary.
    
    #confirm user actually belongs to the Season associated with this Contract/Market
    if @membership_row.present?
        
      #Confirm number is a positive integer.
      if @number_of_contracts.to_i > 1 || @number_of_contracts.include?(".")
        flash[:alert] = "There was an error processing your request."
      else
        #check if user already has an asset row associated with this contract (contract id matches and category is "contract_quantity_a").
        #If user does, continue, otherwise, display error saying that user needs to purchase assets before they can sell.
        if @starting_contract_asset_row.present?
          #add variable to track contract_asset_row now that we know it must exist:
          @contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity_a"}).at(0) #membership_row.id is probably unnecessary.
          
          #check if they have any contracts to sell
          if @contract_asset_row.quantity < 1
            flash[:alert] = "It looks like you don't have any of " + @contract_row.title + " to sell."
          #check if they have enough available contracts to sell
          elsif @contract_asset_row.quantity < @pos_num_contracts
            flash[:alert] = "It looks like you don't have enough 'yes' of " + @contract_row.title + " to sell."
          else
            #algorithm (C= b * ln(e^(q1/b) + e^(q2/b)...))
            #consider updating contract table to include column for quantity outstanding to avoid many of these calculations
            liquidity_param = 50 #set liquidity parameter (b) for now. Later might allow custommization or make b variable.

            #calculate price/cost by running price_check algo
            total_cost = @contract_row.price_check(@contract_id, liquidity_param, @number_of_contracts, "yes")
            
            #(1) remove accumulated funds from user's season_funds, (2) add contract asset (3) later, make it so this is reflected in transaction table(probably in a first step and base everything off transaction)
            #Update tables based on actions above.

            # remove accumulated funds from user's season_funds. Consider updating method to be based on subtraction from current amount instead of current way.
            @user_season_funds_row.quantity = @user_season_funds_row.quantity - total_cost
            @user_season_funds_row.save

            #update contract quantity in assets table to reflect new purchase
            @contract_asset_row.quantity = @contract_asset_row.quantity + @number_of_contracts.to_i
            @contract_asset_row.save

            #update contract quantity in contracts table to reflect new outstanding balance
            @contract_row.quantity_a = @contract_row.quantity_a + @number_of_contracts.to_i
            @contract_row.save

            if @pos_num_contracts == 1
              flash[:notice] = "Yay! " + @pos_num_contracts.to_s + " yes contract was sucessfully sold for " + number_to_currency((total_cost * -1)) + "."
            else
              flash[:notice] = "Yay! " + @pos_num_contracts.to_s + " yes contracts were sucessfully sold for " + number_to_currency((total_cost * -1)) + "."
            end

          end
        else
          flash[:alert] = "It looks like you don't have any of yes contracts of " + @contract_row.title + " to sell. You'll need to buy some yes contracts before you can sell them."
        end
      end

      #add instance variables needed for partials that are refreshed
      @contract_rows = @contract_row.market.contracts.order({ :created_at => :asc })
      @membership_id = @membership_row.id
      @season_membership_rows = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table"})
      @market_row = @contract_row.market

      respond_to do |format|
        format.js { render 'contract_templates/render_contracts.js.erb' }
      end

    else
      flash[:alert] = "You are not authorized to perform this action."
    end

  end



  #   old algo:

  #   #set trackers and counters
  #   asset_quantity_counter = 0
  #   asset_remaining_tracker = @number_of_contracts.to_i
  #   looper = asset_remaining_tracker
  #   funds_remaining_tracker = @user_starting_season_funds
  #   contracts_remaining_tracker = @contract_asset_row.quantity
  #   asset_price_tracker = @starting_contract_price

  #   #check if user has at least one contract to sell. If not, return them to the screen and alert them of insufficient contracts.
  #   if @contract_asset_row.quantity < 1
  #     flash[:alert] = "It looks like you don't have any of " + @contract_row.title + " to sell. You'll need to buy some contracts before you can sell them."
  #     redirect_to("/markets/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s)
  #     return
  #   else
  #     while looper > 0 
  #       if contracts_remaining_tracker > 0
  #         #increase season funds by amount of current contract price
  #         funds_remaining_tracker = funds_remaining_tracker + asset_price_tracker

  #         #update contracts_remaining_tracker to reflect the number of contracts remaining in user's account that can be sold
  #         contracts_remaining_tracker = contracts_remaining_tracker - 1

  #         #update contract price based on algorithm. Start with simple algorithm that only subtracts 0.005 from contract price each time one is sold.
  #         if asset_price_tracker > 0.000
  #           asset_price_tracker = asset_price_tracker - 0.005
  #         end

  #         #update asset_remaining_tracker to reflect number of assets remaining to be fufilled
  #         asset_remaining_tracker = asset_remaining_tracker - 1
          
  #         #updated asset_quantity_counter to indicate how many were purchased
  #         asset_quantity_counter = asset_quantity_counter + 1 
  #       end

  #       #update looper to remove one loop count
  #       looper = looper - 1

  #     end

  #   end

  #   #(1) add accumulated funds from user's season_funds, (2) add contract asset, (3) update contract price based on algorithm, (4)later, make it so this is reflected in transaction table(probably in a first step and base everything off transaction)
  #     #Update tables based on actions above.

  #     #add accumulated funds to user's season_funds. Consider updating method to be based on addition from current amount instead of current way.
  #     @user_season_funds_row.quantity = funds_remaining_tracker
  #     @user_season_funds_row.save

  #     #update contract quantity in assets table to reflect sale of contracts
  #     @contract_asset_row.quantity = contracts_remaining_tracker
  #     @contract_asset_row.save
      
  #     #update overall contract quantity in contract table
  #     #update contract price based on accumulated new price based on current algo.
  #     #Consider issues with multiple purchases in quick sucession. Better/safer way to do this?
  #     @contract_row.quantity = @contract_row.quantity - asset_quantity_counter
  #     @contract_row.price = asset_price_tracker
  #     @contract_row.save

  #   if asset_remaining_tracker == 0
  #     flash[:notice] = "Yay! All " + asset_quantity_counter.to_s + " contract(s) were sucessfully sold!"
  #   else
  #     flash[:notice] = "Your order has partially completed. You only sold " + asset_quantity_counter.to_s + " contract(s)."
  #   end

  #   redirect_to("/markets/" + @club_id.to_s + "/" + @season_id.to_s + "/" + @market_id.to_s)

  # end

  # #end


    def buy_no_contracts
    #set variables
    @contract_id = params.fetch("contract_id")
    @contract_row = Contract.where({ :id => @contract_id }).at(0)
    @market_id = @contract_row.market.id
    @season_id = @contract_row.market.season.id
    @club_id = @contract_row.market.season.club.id
    
    @number_of_contracts = params.fetch("quantity_buy_no")
    @membership_row = Membership.where({ :users_id => current_user.id, :seasons_id => @season_id, :goes_to => "seasons_table"}).at(0)
    @user_asset_rows = @membership_row.assets
    @user_season_funds_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :category => "season_fund"}).at(0)
    @user_starting_season_funds = @user_season_funds_row.quantity
    @starting_contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity_b"}).at(0) #membership_row.id is probably unnecessary.
    
    #confirm user actually belongs to the Season associated with this Contract/Market
    if @membership_row.present?
      
      #Confirm number is a positive integer.
      if @number_of_contracts.to_i < 1 || @number_of_contracts.include?(".")
        flash[:alert] = "There was an error processing your request."
      else
        #check if user already has an asset row associated with this contract (contract id matches and category is "contract_quantity_b").
        #If user does, skip step, otherwise, if user does not, create a new asset with a quantity of 0.
        if @starting_contract_asset_row.present?
        else
          new_asset = Asset.new
          new_asset.membership_id = @membership_row.id
          new_asset.season_id = @season_id
          new_asset.contract_id = @contract_id
          new_asset.category = "contract_quantity_b"
          new_asset.quantity = 0
          new_asset.save
        end

        #add variable to track contract_asset_row now that we know it must exist:
        @contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity_b"}).at(0) #membership_row.id is probably unnecessary.
        
        #algorithm (C= b * ln(e^(q1/b) + e^(q2/b)...))
        #consider updating contract table to include column for quantity outstanding to avoid many of these calculations
        liquidity_param = 50 #set liquidity parameter (b) for now. Later might allow custommization or make b variable.

        #calculate price/cost by running price_check algo
        total_cost = @contract_row.price_check(@contract_id, liquidity_param, @number_of_contracts, "no")
        
        #(1) remove accumulated funds from user's season_funds, (2) add contract asset (3) later, make it so this is reflected in transaction table(probably in a first step and base everything off transaction)
        #Update tables based on actions above.

        if total_cost > @user_season_funds_row.quantity
          flash[:alert] = "Insufficient funds. Sell some contracts or request more funds from the Season owner."
        else
          # remove accumulated funds from user's season_funds. Consider updating method to be based on subtraction from current amount instead of current way.
          @user_season_funds_row.quantity = @user_season_funds_row.quantity - total_cost
          @user_season_funds_row.save

          #update contract quantity in assets table to reflect new purchase
          @contract_asset_row.quantity = @contract_asset_row.quantity + @number_of_contracts.to_i
          @contract_asset_row.save

          #update contract quantity in contracts table to reflect new outstanding balance
          #if market is a 'Classical' category, then instead of adding a no contract, add a yes contract for every other contract...at least for now.
          if @contract_row.category == "Classical"
            @contract_row.market.contracts.where.not({ :id => @contract_row.id }).each do |add_contract|
              add_contract.quantity_a = add_contract.quantity_a + @number_of_contracts.to_i
              add_contract.save
            end
          elsif @contract_row.category == "Independent"
            @contract_row.quantity_b = @contract_row.quantity_b + @number_of_contracts.to_i
            @contract_row.save
          end

          if @number_of_contracts.to_i == 1
            flash[:notice] = "Yay! " + @number_of_contracts.to_s + " no contract was sucessfully purchased for " + number_to_currency(total_cost) + "."
          else
            flash[:notice] = "Yay! " + @number_of_contracts.to_s + " no contracts were sucessfully purchased for " + number_to_currency(total_cost) + "."
          end
        end
      end
      
      #add instance variables needed for partials that are refreshed
      @contract_rows = @contract_row.market.contracts.order({ :created_at => :asc })
      @membership_id = @membership_row.id
      @season_membership_rows = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table"})
      @market_row = @contract_row.market

      respond_to do |format|
        format.js { render 'contract_templates/render_contracts.js.erb' }
      end

    else
      flash[:alert] = "You are not authorized to perform this action."
    end

  end

  

  def sell_no_contracts
    #set variables
    @contract_id = params.fetch("contract_id")
    @contract_row = Contract.where({ :id => @contract_id }).at(0)
    @market_id = @contract_row.market.id
    @season_id = @contract_row.market.season.id
    @club_id = @contract_row.market.season.club.id
    
    @number_of_contracts = (params.fetch("quantity_sell_no").to_i * -1).to_s
    @pos_num_contracts = @number_of_contracts.to_i * -1
    @membership_row = Membership.where({ :users_id => current_user.id, :seasons_id => @season_id, :goes_to => "seasons_table"}).at(0)
    @user_asset_rows = @membership_row.assets
    @user_season_funds_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :category => "season_fund"}).at(0)
    @user_starting_season_funds = @user_season_funds_row.quantity
    @starting_contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity_b"}).at(0) #membership_row.id is probably unnecessary.
    
    #confirm user actually belongs to the Season associated with this Contract/Market
    if @membership_row.present?
  
      #Confirm number is a positive integer.
      if @number_of_contracts.to_i > 1 || @number_of_contracts.include?(".")
        flash[:alert] = "There was an error processing your request."
      else
        #check if user already has an asset row associated with this contract (contract id matches and category is "contract_quantity_b").
        #If user does, continue, otherwise, display error saying that user needs to purchase assets before they can sell.
        if @starting_contract_asset_row.present?
          #add variable to track contract_asset_row now that we know it must exist:
          @contract_asset_row = @user_asset_rows.where({ :membership_id => @membership_row.id, :contract_id => @contract_id, :category => "contract_quantity_b"}).at(0) #membership_row.id is probably unnecessary.
          
          #check if they have any contracts to sell
          if @contract_asset_row.quantity < 1
            flash[:alert] = "It looks like you don't have any of " + @contract_row.title + " to sell. You'll need to buy some contracts before you can sell them."
          #check if they have enough available contracts to sell
          elsif @contract_asset_row.quantity < @pos_num_contracts
            flash[:alert] = "It looks like you don't have enough 'no' of " + @contract_row.title + " to sell."
          else
            #algorithm (C= b * ln(e^(q1/b) + e^(q2/b)...))
            #consider updating contract table to include column for quantity outstanding to avoid many of these calculations
            liquidity_param = 50 #set liquidity parameter (b) for now. Later might allow custommization or make b variable.

            #calculate price/cost by running price_check algo
            #convert quantity of contracts back to positive number for purposes of price_check calculation
            
            if @contract_row.category == "Classical"
              positive_number_of_contracts = (@number_of_contracts.to_i * -1).to_s
            
              total_cost = @contract_row.price_check(@contract_id, liquidity_param, positive_number_of_contracts, "no")
            
              #convert total cost to negative to calculate 'price' paid

              total_cost = total_cost * -1
            elsif @contract_row.category == "Independent"
              total_cost = @contract_row.price_check(@contract_id, liquidity_param, @number_of_contracts, "no")
            end
            
            #(1) remove accumulated funds from user's season_funds, (2) add contract asset (3) later, make it so this is reflected in transaction table(probably in a first step and base everything off transaction)
            #Update tables based on actions above.

            # remove accumulated funds from user's season_funds. Consider updating method to be based on subtraction from current amount instead of current way.
            @user_season_funds_row.quantity = @user_season_funds_row.quantity - total_cost
            @user_season_funds_row.save

            #update contract quantity in assets table to reflect new purchase
            @contract_asset_row.quantity = @contract_asset_row.quantity + @number_of_contracts.to_i
            @contract_asset_row.save

            #update contract quantity in contracts table to reflect new outstanding balance
            #if market is a 'Classical' category, then instead of adding a no contract, add a yes contract for every other contract...at least for now.
            if @contract_row.category == "Classical"
              @contract_row.market.contracts.where.not({ :id => @contract_row.id }).each do |add_contract|
                add_contract.quantity_a = add_contract.quantity_a + @number_of_contracts.to_i
                add_contract.save
              end
            elsif @contract_row.category == "Independent"
              @contract_row.quantity_b = @contract_row.quantity_b + @number_of_contracts.to_i
              @contract_row.save
            end
            
            if @pos_num_contracts == 1
              flash[:notice] = "Yay! " + @pos_num_contracts.to_s + " no contract was sucessfully sold for " + number_to_currency((total_cost * -1)) + "."
            else
              flash[:notice] = "Yay! " + @pos_num_contracts.to_s + " no contracts were sucessfully sold for " + number_to_currency((total_cost * -1)) + "."
            end
          end
        else
          flash[:alert] = "It looks like you don't have any of " + @contract_row.title + " to sell. You'll need to buy some contracts before you can sell them."
        end
      end
        #add instance variables needed for partials that are refreshed
        @contract_rows = @contract_row.market.contracts.order({ :created_at => :asc })
        @membership_id = @membership_row.id
        @season_membership_rows = Membership.where({ :seasons_id => @season_id, :goes_to => "seasons_table"})
        @market_row = @contract_row.market

        respond_to do |format|
          format.js { render 'contract_templates/render_contracts.js.erb' }
        end

    else
      flash[:alert] = "You are not authorized to perform this action."
    end

  end


end