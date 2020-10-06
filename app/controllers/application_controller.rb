class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?
  
   
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname])
  end
  
  # ログイン後のページ
  def after_sign_in_path_for(resource) 
    if session[:privious_url] != root_path
      session[:privious_url]
    else
      user_profile_path
    end
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
      
      # url情報の保管
      def store_location
        session[:privious_url] = request.fullpath if request.path != new_user_session_path &&
                                                     request.path != new_user_registration_path &&
                                                     request.fullpath != '/users' && # 入力エラー後
                                                     !request.xhr?
      end
      
      # 開催日時を返す
      def to_date_and_time(date, datetime)
        @date = date
        @datetime = datetime
        @start_datetime = Time.new(@date.year, @date.month, @date.day, @datetime.hour, 
                            @datetime.min, 0, "+09:00")
        return @start_datetime
      end
      
      # 開催日時を返す
      def to_date_and_time_three(date, hour, min)
        @date = date
        @start_datetime = Time.new(@date.year, @date.month, @date.day, hour, 
                            min, 0, "+09:00")
        return @start_datetime
      end
end
