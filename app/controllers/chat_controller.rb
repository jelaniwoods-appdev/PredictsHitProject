class ChatController < ApplicationController

  def create_live_club_message
    club_id = params.fetch("club_id")
    user_id = params.fetch("user_id")
    message_body = params.fetch("live_body")
    
    #confirm user actually belongs to the Club that the message is sent in and that user submitting form is the right user
    if (user_id == current_user.id.to_s) && (Membership.where({ :clubs_id => club_id, :goes_to => "clubs_table", :users_id => current_user.id }).at(0).present?)
      @message = Chat.new
      @message.goes_to = "club"
      @message.status = "active"
      @message.clubs_id = club_id
      @message.goes_to_id = club_id
      @message.body = message_body
      @message.users_id = user_id
      if @message.valid?
        @message.save
        @message_username = User.where({ :id => @message.users_id }).at(0).username
        @message_prof_pic = User.where({ :id => @message.users_id }).at(0).prof_pic.url
        
        ActionCable.server.broadcast "room_channel#{@message.clubs_id}", { body: @message.body, username: @message_username, prof_pic: @message_prof_pic }
        head :no_content
      else
      end
    else
     flash[:alert] = "You are not authorized to perform this action."
    end
    


  end





  def create_club_message
    club_id = params.fetch("club_id")
    user_id = params.fetch("user_id")
    message_body = params.fetch("body")
    
    #confirm user actually belongs to the Club that the message is sent in and that user submitting form is the right user
    if (user_id == current_user.id.to_s) && (Membership.where({ :clubs_id => club_id, :goes_to => "clubs_table", :users_id => current_user.id }).at(0).present?)
      @message = Chat.new
      @message.goes_to = "club"
      @message.status = "active"
      @message.clubs_id = club_id
      @message.goes_to_id = club_id
      @message.body = message_body
      @message.users_id = user_id
      if @message.valid?
        @message.save
      else
      end

      #add instance variables needed for comments partial that is refreshed
      @club_messages = Chat.where({ :clubs_id => @message.clubs_id, :goes_to => "club" }).order({ :created_at => :desc })
      @club_row = @message.club

      respond_to do |format|
        format.js { render 'club_templates/render_messages.js.erb' }
      end
      
    else
     flash[:alert] = "You are not authorized to perform this action."
    end
    


  end


  def create_season_message
    
    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    user_id = params.fetch("user_id")
    message_body = params.fetch("body")
    
    #confirm user actually belongs to the Season that the message is sent in and that user submitting form is the right user
    if (user_id == current_user.id.to_s) && (Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table", :users_id => user_id }).at(0).present?)

      @message = Chat.new
      @message.goes_to = "season"
      @message.status = "active"
      @message.clubs_id = club_id
      @message.seasons_id = season_id
      @message.goes_to_id = season_id
      @message.body = message_body
      @message.users_id = user_id
      if @message.valid?
        @message.save
      else
      end

      #add instance variables needed for comments partial that is refreshed
      @season_messages = Chat.where({ :seasons_id => @message.seasons_id, :goes_to => "season" }).order({ :created_at => :desc })
      @club_row = @message.season.club
      @season_row = @message.season

      respond_to do |format|
        format.js { render 'season_templates/render_messages.js.erb' }
      end

    else
    end

  end

  def create_market_message

    club_id = params.fetch("club_id")
    season_id = params.fetch("season_id")
    market_id = params.fetch("market_id")
    user_id = params.fetch("user_id")
    message_body = params.fetch("body")

    #confirm user actually belongs to the Season containing the market that the message is sent in and that user submitting form is the right user
    if (user_id == current_user.id.to_s) && (Membership.where({ :seasons_id => season_id, :goes_to => "seasons_table", :users_id => user_id }).at(0).present?)

      @message = Chat.new
      @message.goes_to = "market"
      @message.status = "active"
      @message.clubs_id = club_id
      @message.seasons_id = season_id
      @message.markets_id = market_id
      @message.goes_to_id = market_id
      @message.body = message_body
      @message.users_id = user_id
      if @message.valid?
        @message.save
      else
      end

      #add instance variables needed for comments partial that is refreshed
      @market_messages = Chat.where({ :markets_id => @message.markets_id, :goes_to => "market" }).order({ :created_at => :desc })
      @club_row = @message.market.season.club
      @season_row = @message.market.season
      @market_row = @message.market

      respond_to do |format|
        format.js { render 'market_templates/render_messages.js.erb' }
      end

    else
    end

  end

end
