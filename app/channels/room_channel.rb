class RoomChannel < ApplicationCable::Channel
  def subscribed
    return false unless %w[market season club].include?(params[:room_type])

    if params[:room_type] == "club" || params[:room_type] == "season"
      membership = current_user.memberships.where(
        goes_to: "#{params[:room_type]}s_table", 
        "#{params[:room_type]}" => params[:room_id]
      ).first
    elsif params[:room_type] == "market"
      associated_season_id = Market.where(id: params[:room_id]).first.season_id
      membership = current_user.memberships.where(
        goes_to: "seasons_table", 
        "season" => associated_season_id
      ).first

    end
    
    return false unless membership.present?
    stream_from "room_channel_#{params[:room_type]}_#{params[:room_id]}"

  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

end
