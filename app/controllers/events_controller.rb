class EventsController < ApplicationController
    before_action :user_info, only: [:new, :create, :confirm]  
    # before_action :move_to_index, except: [:index,:show ]
    # indexアクション以外が実行される前にindexが実行される。
    
  def top
    @events_all = Event.includes(:user).order("start_date DESC").page(params[:page]).per(5)
    
    if params[:date].present?
      @events = @events_all.where(start_date: params[:date].in_time_zone.all_day).page(params[:page]).per(5)
    elsif params[:max].present? || params[:min].present?
      @events = @events_all.where(price: params[:min].. params[:max]).page(params[:page]).per(5)
    
    else
      @events = @events_all.order("start_date DESC").page(params[:page]).per(5)
      
    end
  end

  # イベントの新規登録
  def new
    @event = Event.new
  end
  
  # イベント作成アクション
  def create
    @event = Event.new(event_params)
    @event.user_id = current_user.id
    if @event.save
      flash[:notice] = "イベントの登録が完了しました！"
      redirect_to events_confirm_path
    else
      flash[:notice] = "入力いただいた情報に誤りがあります。"
      render :new
    end
  end
  
  # イベントの編集
  def edit
    @event = Event.find(params[:id])
  end
  
  
  def update
    @event = Event.find(params[:id])
    if @event.update(event_params)
      redirect_to events_confirm_path  
    else
      flash[:notice] = "エラーが発生しました。もう一度やり直してください。"
    end
  end
  
  
  def confirm
    @events = Event.where(user_id: @user.id)
  end

  # イベント詳細表示
  def show
    @event = Event.find(params[:id])
    @reserves = Reserve.where(event_id: params[:id])
    
    @reserve = Reserve.new
    @user = User.new
  end
  
  def destroy
    event = Event.find(params[:id])
    if event.user_id == current_user.id
      event.destroy
    end
  end
  
    private
      def event_params
        params.require(:event).permit(:title, :start_date, :start_time, :venue, :price, :content, :capacity)
      end
      
      def move_to_index
       redirect_to action: :index unless user_signed_in?
      end
end
