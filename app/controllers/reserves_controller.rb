class ReservesController < ApplicationController
  def create
    Reserve.create(nickname: reserve_params[:nickname], email: reserve_params[:email], event_id: reserve_params[:event_id])
    redirect_to "/events/#{reserve_params[:event_id]}"
  end
  
  private
  def reserve_params
    params.permit(:nickname, :email, :event_id)
  end
end