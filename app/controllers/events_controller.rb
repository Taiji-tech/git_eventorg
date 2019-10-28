class EventsController < ApplicationController
  
      before_action :move_to_index, except: [:index,:show ]
    # indexアクション以外が実行される前にindexが実行される。
    
  def index
 
    @events = Event.includes(:user).order("start DESC").page(params[:page]).per(5)
    
  end

  def new
  end
  
  def create

    file_name = "#{event_params[:title]}-#{current_user.id}.jpg"
    
    if event_params[:image]
      #受け取った画像データを保存（画像データを元に画像ファイルを作成）する
      image = event_params[:image]
      File.binwrite("app/app/assets/images/#{file_name}", image.read)
    else
      file_name = "noimage.jpg"
    end
    
    Event.create(
      title: event_params[:title],
      start: event_params['start(1i)']+'-'+event_params['start(2i)']+'-'+event_params['start(3i)']+' '+event_params['start(4i)']+':'+event_params['start(5i)'],
      venue: event_params[:venue],
      content: event_params[:content],
      capacity: event_params[:capacity],
      user_id: current_user.id,
      image: file_name
      )

    
      
  end
  
   def show
     @event = Event.find(params[:id])
     @reserves = @event.reserves
   end
  
  def destroy
    event = Event.find(params[:id])
    if event.user_id == current_user.id
      event.destroy
      if event.image != "noimage.jpg"
        File.delete("app/app/assets/images/#{event.title}-#{current_user.id}.jpg")
      end
    end
  end
  
  private
  def event_params
   params.require('/events').permit(:title, :start, :venue, :content, :capacity, :image )
  end
  
  def move_to_index
   redirect_to action: :index unless user_signed_in?
  end
end
