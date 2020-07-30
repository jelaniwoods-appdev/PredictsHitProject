class ChatController < ApplicationController

  def create_club_message
    @message = Chat.new
    @message.goes_to = "club"
    @message.status = "active"
    @message.clubs_id = params.fetch("club_id")
    @message.goes_to_id = params.fetch("club_id")
    @message.body = params.fetch("body")
    @message.users_id = params.fetch("user_id")
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

  end

end