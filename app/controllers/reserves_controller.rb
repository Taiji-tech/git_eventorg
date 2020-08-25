class ReservesController < ApplicationController
  
  # ユーザー登録を行わない予約
  def create
    @event = Event.find(params[:event_id])
    
    # ログイン後の予約
    if user_signed_in?
      @reserve = Reserve.new(nickname: current_user.nickname, email: current_user.email, 
                            event_id: params[:event_id])
      if @reserve.save
        respond_to do |format|
          format.js
        end
      else
        flash[:notice] = "入力に誤りがあります"
      end
    # ログインのない予約＝ユーザー登録なし
    else
      @reserve = Reserve.new(reserve_params) 
      @reserve.event_id = params[:event_id]
      if @reserve.save
        respond_to do |format|
          format.js
        end
      else
        flash[:notice] = "入力に誤りがあります"
      end
    end
  end
  
  # ユーザー登録も行う予約
  def createWithResistration
    @event = Event.find(params[:event_id])
    @user = User.new(user_params)
    @reserves = Reserve.where(event_id: params[:event_id])
    
    if @user.save
      # 予約処理も併せて行う
      @reserve = Reserve.new(event_id: params[:event_id], nickname: @user.nickname, email: @user.email)
      @reserve.save
      respond_to do |format|
        format.js
      end
    else
      # やり直し
      flash[:notice] = "入力に誤りがあります"
      render "events/show"
    end
  end
  
    private
      def reserve_params
        params.require(:reserve).permit(:nickname, :email, :event_id)
      end
      
      def user_params
        params.require(:user).permit(:nickname, :email, :password, :password_confirmation)
      end
end