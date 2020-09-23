class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :confirm]
  before_action :user_info, only: [:new, :create, :confirm] 
  before_action :tenant_resistration, only: [:new, :create]
  after_action :store_location
  # before_action :move_to_index, except: [:index,:show ]
  # indexアクション以外が実行される前にindexが実行される。
  require 'base64'
    
  # トップ画面、イベント検索  
  def top
    @events = Event.includes(:user).order("start_date ASC")
    not_expired_event
    @events = @events.order("start_date ASC")
    if params[:venue_method].present?
      @events = @events.where(venue_method: params[:venue_method])
    end
    if params[:date].present?
      @events = @events.where(start_date: params[:date].in_time_zone.all_day)
    end
    if params[:max].present? && params[:min].present?
      @events = @events.where(price: params[:min] .. params[:max])
    elsif params[:max].present?
      @events = @events.where(price: Float::MIN .. params[:max].to_i)
    elsif params[:min].present?
      @events = @events.where(price: params[:min].to_i .. Float::INFINITY)
    end
    if params[:keyword].present?
      @events = @events.where("title LIKE ?", "%#{params[:keyword]}%")
    end
    @events = @events.page(params[:page]).per(10)
  end

  # イベントの新規登録画面
  def new
    @event = Event.new
  end
  
  # イベントの新規登録
  def create
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    if @event.save
      EventMailer.mail_event_create(@event).deliver_now
      flash[:notice] = "イベントの登録が完了しました！"
      redirect_to events_confirm_path
    else
      render "inputError.js.erb"
    end
  end
  
  # イベントの編集画面
  def edit
    @event = Event.find(params[:id])
  end
  
  # イベント情報の更新
  def update
    @event = Event.find(params[:id])
    @deleteImgs = params[:event][:deleteImg]
    @imgs = @deleteImgs[0].split(',')
    
    if @imgs.size == @event.imgs.size
      flash[:notice] = "画像は必ず登録してください。"
      redirect_to session[:privious_url]
    else

      if @event.update(event_params)
        @imgs.each do |i|
          @index = i.to_i
          @event.imgs[@index].purge
        end
        flash[:notice] = "イベントの情報が更新されました！"
        redirect_to events_confirm_path  
      else
        render "inputError.js.erb"
      end
    end
  end
  
  
  def confirm
    @events = Event.where(user_id: @user.id).page(params[:page]).per(5)
    if user_signed_in?
      @card = Card.find_by(user_id: current_user.id)
    end
  end

  # イベント詳細表示
  def show
    @event = Event.includes(:user).find(params[:id])
    @reserves = Reserve.where(event_id: params[:id])
    
    @reserve = Reserve.new
    @user = User.new
  end
  
  # イベントの削除
  def destroy
    @event = Event.find(params[:id])
    @reserves = Reserve.where(event_id: @event.id) 
    if @event.user_id == current_user.id
      reserves_cancel
      @event.destroy
      EventMailer.mail_event_destroy(@event).deliver_now
      flash[:notice] = "イベントをキャンセルしました。"
      redirect_to events_confirm_path
    else
      flash[:notice] = "イベントをキャンセルできませんでした。"
      redirect_to events_confirm_path
    end
  end
  
    private
      def event_params
        params.require(:event).permit(:title, :start_date, :start_time, :venue_method, :venue, :venue_pass, :price, :content, :capacity, imgs: [])
      end
      
      def move_to_index
       redirect_to action: :index unless user_signed_in?
      end
      
      # テナント登録してない場合、新規イベント登録不可
      def tenant_resistration 
        @tenant = Tenant.find_by(user_id: current_user.id)
        unless @tenant.present?
          flash[:notice] = "イベント登録前に銀行口座登録を行ってください"
          redirect_to user_pays_hostnew_path
        end
      end
      
      # イベントの予約をすべてキャンセル
      def reserves_cancel
        @reserves.each do |reserve|
          @reserve = reserve  
          # 支払い済みの場合
          if @reserve.payed
            payjp_cancel_action
          end
          if @reserve.destroy
            ReserveMailer.mail_event_destroy_for_user(@reserve).deliver_now
            ReserveMailer.mail_cancel_complite(@reserve).deliver_now
          else
            flash[:notice] = "イベントのキャンセルに失敗しました。"
            redirect_to session[:privious_url]
          end
        end
      end
      
      # 支払い情報の保存
      def pay_db_resister
        @pay_new = Pay.new(host_id: @event.user_id, price: - @event.price, 
                       card_id: @pay.id, reserve_id: @reserve.id, charge_id: @pay.charge_id)
        @pay_new.user_id = current_user.id if user_signed_in?
        @pay_new.save
      end
      
      # payjpキャンセルアクション
      def payjp_cancel_action
        begin
          Payjp.api_key = ENV["PAYJP_PRIVATE_KEY"]
          @pay = Pay.find_by(reserve_id: @reserve.id)
          charge = Payjp::Charge.retrieve(@pay.charge_id)
          charge.refund
          pay_db_resister
          @reserve.update(payed: false)
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
