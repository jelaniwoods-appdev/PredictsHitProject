class RoomChannel < ApplicationCable::Channel
  def subscribed
    return false unless %w[market season club].include?(params[:room_type])

    membership = current_user.memberships.where(
      goes_to: "#{params[:room_type]}s_table", 
      "#{params[:room_type]}" => params[:room_id]
    ).first

    return false unless membership.present?

    stream_from "room_channel_#{params[:room_type]}_#{params[:room_id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
