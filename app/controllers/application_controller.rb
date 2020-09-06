class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
 
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
  end
  
  
    private 
      def user_info 
        @user = User.find(current_user.id)
      end
      
      def not_expired_event
        @events = Event.includes(:user).all
        @events = @events.where(start_date: Time.zone.now .. Float::INFINITY)
      end
      
      # boolean変換メソッド
      def to_bool(func)
        if func == "true"
          return true
        elsif func == "false"
          return false
        end
      end
end
