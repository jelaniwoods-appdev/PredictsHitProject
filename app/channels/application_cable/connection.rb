module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
 
    def connect
      self.current_user = find_verified_user
    end
 
    private
      def find_verified_user
        verified_user = env['warden'].user
        if verified_user.confirmed_at.present?
          verified_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
