class EventsController < ApplicationController
  
      before_action :move_to_index, except: [:index,:show ]
    # indexアクション以外が実行される前にindexが実行される。
    
  def index
    @events = Event.includes(:user).order("start DESC").page(params[:page]).per(5)
  end

  def new
  end
  
  def create
    Event.create(title: event_params[:title], start: event_params[:start], venue: event_params[:venue], content: event_params[:content], capacity: event_params[:capacity], user_id: current_user.id)
  end
  
   def show
     @event = Event.find(params[:id])
     @reserves = @event.reserves
   end
  
  def destroy
    event = Event.find(params[:id])
    if event.user_id == current_user.id
      event.destroy
    end
  end
  
  private
  def event_params
    params.permit(:title, :start, :venue, :content, :capacity)
  end
  
  def move_to_index
   redirect_to action: :index unless user_signed_in?
  end
end
