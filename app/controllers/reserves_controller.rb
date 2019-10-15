class ReservesController < ApplicationController
  def create
    Reserve.create(nickname: params[:nickname], email: params[:email], event_id: params[:event_id])
    redirect_to "/events/#{@reserve.event.id}"
  end
  
  private
  def reserve_params
    params.permit(:nickname, :email, :event_id)
  end
end