class RoomChannel < ApplicationCable::Channel
  def subscribed
    stream_from "room_channel#{params[:room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
