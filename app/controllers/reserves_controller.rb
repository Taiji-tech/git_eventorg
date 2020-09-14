class ReservesController < ApplicationController
  require 'payjp'
  before_action :authenticate_user!, only: [:reserved]
  before_action :only_one_reserve, only: [:create, :createWithResistration]
  before_action :same_user, only: [:create, :createWithResistration]
  before_action :over_time, only: [:destroy]
  after_action :store_location
  
  
  # ユーザー登録を行わない予約
  def create
    @event = Event.find(params[:event_id])
    
    # ログイン後の予約
    if user_signed_in?
      @reserve = Reserve.new(nickname: current_user.nickname, email: current_user.email, 
                            event_id: params[:event_id], user_id: current_user.id)
      if @reserve.save
        pay_action_has_account
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
  end
  
  def cancel
    @reserve = Reserve.includes(:event).find(params[:id])
    @event = @reserve.event
  end
  
  # キャンセル
  def destroy
    @reserve = Reserve.find(params[:id])
    
    # 支払い済みの場合
    if @reserve.payed
      payjp_cancel_action
    end
    if @reserve.destroy
      flash[:notice] = "イベントのキャンセルが完了しました"
      ReserveMailer.mail_cancel_complite(@reserve).deliver_now
      if user_signed_in?
        redirect_to user_reserved_path(future: true, past: true)
      else
        redirect_to root_path
      end
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
      UserMailer.mail_user_registered(@user).deliver_now
      @reserve = Reserve.new(event_id: params[:event_id], nickname: @user.nickname, 
                             email: @user.email, user_id: @user.id)
      @reserve.save
      pay_action_has_account
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
      @reserves = @reserves_current_user.where(events: {start_date: Time.zone.now..Float::INFINITY}).page(params[:page]).per(5)
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
            flash[:notice] = "イベント主催者が予約することはできません"
            redirect_to event_path(params[:event_id])
          end
        end
      end
      
      # イベント開催日時経過後のキャンセル不可
      def over_time
        @reserve = Reserve.includes(:event).find(params[:id])
        @event = @reserve.event
        @deadline = to_date_and_time(@event.start_date, @event.start_time)
        unless @deadline >= Time.zone.now 
          flash[:notice] = "イベント開催日を過ぎており、キャンセルできません。"
          redirect_to session[:privious_url]
        end
      end
      
      # 支払い情報の管理
      def pay_db_resister
        @pay = Pay.new(host_id: @event.user_id, price: @event.price, 
                       card_id: @card.id, reserve_id: @reserve.id, charge_id: @charge.id)
        @pay.user_id = current_user.id if user_signed_in?
        @pay.save
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
            @charge = Payjp::Charge.create(
              amount: @event.price.to_i,
              customer: @card.customer_id,
              currency: 'jpy',
              tenant: @tenant.tenant_id
            )
            pay_db_resister
            @reserve.update(payed: true)
            PayMailer.mail_pay_complite(@reserve).deliver_now
          
          rescue Payjp::CardError => e
            flash[:notice] = '支払い時に必要なカード情報の取得ができませんでした。'
            render "payError.js"
          rescue Payjp::InvalidRequestError => e
            flash[:notice] = '支払い時に不正なパラメータが入力されました。'
            render "payError.js"
          rescue Payjp::AuthenticationError => e
            flash[:notice] = '支払い時にカード情報の取得ができませんでした。'
            render "payError.js"
          rescue Payjp::APIConnectionError => e
            flash[:notice] = '支払い時に通信エラーが発生しました。'
            render "payError.js"
          rescue Payjp::APIError => e
            flash[:notice] = '支払い時に通信エラーが発生しました。'
            render "payError.js"
          rescue Payjp::PayjpError => e
            flash[:notice] = 'カード情報の取得ができませんでした。'
            render "payError.js"
          rescue StandardError
            flash[:notice] = 'エラーが発生しました。'
            render "payError.js"
          end
          
        # 支払い情報を持っていない場合  
        else
          # 予約完了メールの送信
          # 支払いリンクの送信
          begin
            ReserveMailer.mail_reserve_complite(@reserve).deliver_now
          rescue StandardError
            flash[:notice] = 'メール通信のエラーが発生しました。'
            render "payError.js"
          end
        end
      end
      
      # アカウントを持っていないユーザーの支払いアクション
      def pay_action_hasnt_account
        # 予約完了メールの送信
        # 支払いリンクの送信
        begin
          ReserveMailer.mail_reserve_complite(@reserve).deliver_now
        rescue StandardError
          flash[:notice] = 'メール通信のエラーが発生しました。'
          render "payError.js"
        end
      end
      
      # イベント予約重複不可
      def only_one_reserve 
        if user_signed_in?
          @already_reserved = Reserve.where(email: current_user.email, event_id: params[:event_id])
          already_reserved_action
        else
          @already_reserved = Reserve.where(email: params[:email], event_id: params[:event_id])
          already_reserved_action
        end
      end
      
      # 予約済みアクション
      def already_reserved_action
        if @already_reserved.present?
          flash[:notice] = "すでにこのイベントは予約済みです。"
          redirect_to session[:privious_url] || root_path
        end
      end
      
      # payjpキャンセルアクション
      def payjp_cancel_action
        begin
          Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
          @pay = Pay.find_by(reserve_id: @reserve.id)
          charge = Payjp::Charge.retrieve(@pay.charge_id)
          charge.refund
          @reserve.payed = false
        rescue Payjp::CardError => e
          flash[:notice] = 'カード情報の取得ができませんでした。'
          render "payError.js"
        rescue Payjp::InvalidRequestError => e
          flash[:notice] = '不正なパラメータが入力されました。'
          render "payError.js"
        rescue Payjp::AuthenticationError => e
          flash[:notice] = 'カード情報の取得ができませんでした。'
          render "payError.js"
        rescue Payjp::APIConnectionError => e
          flash[:notice] = '通信エラーが発生しました。'
          render "payError.js"
        rescue Payjp::APIError => e
          flash[:notice] = '通信エラーが発生しました。'
          render "payError.js"
        rescue Payjp::PayjpError => e
          flash[:notice] = 'カード情報の取得ができませんでした。'
          render "payError.js"
        rescue StandardError
          flash[:notice] = 'エラーが発生しました。'
          render "payError.js"
        end
      end
end