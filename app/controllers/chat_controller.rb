class ChatController < ApplicationController

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
        @message_username = User.where({ :id => @message.users_id }).at(0).username
        @message_prof_pic = User.where({ :id => @message.users_id }).at(0).prof_pic.url
        
        ActionCable.server.broadcast "room_channel_club_#{@message.clubs_id}", { body: @message.body, username: @message_username, prof_pic: @message_prof_pic }
        head :no_content
      else
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
        @message_username = User.where({ :id => @message.users_id }).at(0).username
        @message_prof_pic = User.where({ :id => @message.users_id }).at(0).prof_pic.url
        
        ActionCable.server.broadcast "room_channel_season_#{@message.seasons_id}", { body: @message.body, username: @message_username, prof_pic: @message_prof_pic }
        head :no_content
      else
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
        @message_username = User.where({ :id => @message.users_id }).at(0).username
        @message_prof_pic = User.where({ :id => @message.users_id }).at(0).prof_pic.url
        
        ActionCable.server.broadcast "room_channel_market_#{@message.markets_id}", { body: @message.body, username: @message_username, prof_pic: @message_prof_pic }
        head :no_content
      else
      end

    else
    end

  end

end
