class ReservesController < ApplicationController
  require 'payjp'
  
  before_action :same_user, only: [:create, :createWithResistration]
  
  
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
        ReserveMailer.mail_reserve_complite(@reserve).deliver
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
      
      # イベント主催者による登録不可
      def same_user
        @event = Event.find(params[:event_id])
        if @event.user_id == current_user.id
          flash.now[:notice] = "イベント主催者が予約することはできません"
          redirect_to event_path(params[:event_id])
        end
      end
      
      # アカウント持ちユーザーの支払いアクション
      def pay_action_has_account 
        @card = Card.find_by(user_id: current_user.id)
        @tenant = Tenant.find_by(user_id: @event.user_id)
        if @card.present?
          # 予約完了メールの送信
          ReserveMailer.mail_reserve_complite(@reserve).deliver
          # 支払い
          begin 
            Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
            charge = Payjp::Charge.create(
              :amount => @event.price,
              :customer => @card.customer_id,
              :currency => 'jpy',
              :tenant => @tenant.tenant_id
            )
          # 支払い完了メールの送信
          
          # 予約したイベント一覧画面へ
          redirect_to user_profile_path
          rescue
          
          end
        else
          # 予約完了メールの送信
          # 支払いリンクの送信
          ReserveMailer.mail_reserve_complite(@reserve).deliver
          # 予約したイベント一覧画面へ
          redirect_to user_profile_path
        end
      end
      
      # アカウントを持っていないユーザーの支払いアクション
      def pay_action_hasnt_account
        # 予約完了メールの送信
        # 支払いリンクの送信
         
         
        
      end
end