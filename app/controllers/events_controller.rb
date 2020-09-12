class EventsController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy, :confirm]
  before_action :user_info, only: [:new, :create, :confirm] 
  before_action :tenant_resistration, only: [:new, :create]
  after_action :store_location
  # before_action :move_to_index, except: [:index,:show ]
  # indexアクション以外が実行される前にindexが実行される。
  
    
  # トップ画面、イベント検索  
  def top
    @events = Event.includes(:user).order("start_date DESC").page(params[:page]).per(10)
    not_expired_event
    @events = @events.order("start_date DESC").page(params[:page]).per(10)
    if params[:date].present?
      @events = @events.where(start_date: params[:date].in_time_zone.all_day).page(params[:page]).per(10)
    elsif params[:max].present? && params[:min].present?
      @events = @events.where(price: params[:min] .. params[:max]).page(params[:page]).per(10)
    elsif params[:max].present?
      @events = @events.where(price: Float::MIN .. params[:max].to_i).page(params[:page]).per(10)
    elsif params[:min].present?
      @events = @events.where(price: params[:min].to_i .. Float::INFINITY).page(params[:page]).per(10)
    end
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
    if @event.update(event_params)
      flash.now[:notice] = "イベントの情報が更新されました！"
      redirect_to events_confirm_path  
    else
      render "inputError.js.erb"
    end
  end
  
  
  def confirm
    @events = Event.where(user_id: @user.id).page(params[:page]).per(5)
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
    event = Event.find(params[:id])
    if event.user_id == current_user.id
      event.destroy
    end
  end
  
    private
      def event_params
        params.require(:event).permit(:title, :start_date, :start_time, :venue, :venue_pass, :price, :content, :capacity, imgs: [])
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
      
end
