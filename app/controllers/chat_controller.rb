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
      flash[:notice] = 'Your message was successfully added!'
      redirect_to("/clubs/"+@message.clubs_id.to_s)
    else
      flash[:alert] = 'Your message was NOT added!'
      redirect_to("/clubs/"+@message.clubs_id.to_s)
    end
  end

end
