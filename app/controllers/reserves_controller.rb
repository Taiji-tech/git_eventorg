class ReservesController < ApplicationController
  require 'payjp'
  
  before_action :same_user, only: [:create, :createWithResistration]
  
  # ユーザー登録を行わない予約
  def create
<<<<<<< HEAD
    Reserve.create(nickname: reserve_params[:nickname], email: reserve_params[:email], event_id: reserve_params[:event_id])
    redirect_to "/events/#{reserve_params[:event_id]}"
  end
  
  def destroy
     @reserve = Reserve.where(event_id: params[:event_id])
     @reserve.each do |reserve|
     if ( reserve.nickname == params[:nickname] && reserve.email == params[:email])
       reserve.destroy
     else
       #ニックネームとEメールが存在しない時の処理が必要
     end
   end
     redirect_to "/events/#{reserve_params[:event_id]}"
=======
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
        render "inputError.js.erb"
      end
      
    # ログインのない予約＝ユーザー登録なし
    else
      @reserve = Reserve.new(reserve_params) 
      @reserve.event_id = params[:event_id]
      if @reserve.save
        pay_action_hasnt_account
        respond_to do |format|
          format.js
        end
      else
        render "inputError.js.erb"
      end
    end
>>>>>>> dc21a8650bcc40630bd6fd1c0917b48181565942
  end
  
  # キャンセル
  def destroy
    @reserve = Reserve.find(params[:id])
    
    if @reserve.destroy
      flash.now[:notice] = "イベントのキャンセルが完了しました"
      redirect_to user_reserved_path
    else
      render :reserved
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
      render "inputError.js.erb"
    end
  end
  
  # 予約済みイベントの管理
  def reserved
    @future = params[:future].to_s
    @past = params[:past].to_s
    
    @reserves_current_user = Reserve.includes(:event).where(email: current_user.email)
    if to_bool(@future) && to_bool(@past)
      @reserves = @reserves_current_user.page(params[:page]).per(5)
    elsif to_bool(@future)
      @reserves = @reserves_current_user.where(events: {start_date: Time.zone.now .. Float::INFINITY}).page(params[:page]).per(5)
    elsif to_bool(@past)
      @reserves = @reserves_current_user.where(events: {start_date: "1900-01-01 00:00:00 +0900" .. Time.zone.now}).page(params[:page]).per(5)
    else  
      @reserves = nil
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
        if user_signed_in?
          @event = Event.find(params[:event_id])
          if @event.user_id == current_user.id
            flash.now[:notice] = "イベント主催者が予約することはできません"
            redirect_to event_path(params[:event_id])
          end
        end
      end
      
      # アカウント持ちユーザーの支払いアクション
      def pay_action_has_account 
        @card = Card.find_by(user_id: current_user.id)
        @tenant = Tenant.find_by(user_id: @event.user_id)
        
        # 支払い情報を持っているユーザー
        if @card.present?
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
          @reserve.update(payed: true)
          ReserveMailer.mail_reserve_complite(@reserve).deliver
          redirect_to user_profile_path
          rescue
          
          end
          
        # 支払い情報を持っていない場合  
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
        ReserveMailer.mail_reserve_complite(@reserve).deliver
        # 予約したイベント一覧画面へ
      end
end