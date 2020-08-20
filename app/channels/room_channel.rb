class RoomChannel < ApplicationCable::Channel
  def subscribed
    if params.has_key?("room_type")
      stream_from "room_channel_#{params[:room_type]}_#{params[:room_id]}"
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
