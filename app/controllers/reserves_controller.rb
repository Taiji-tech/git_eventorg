class ReservesController < ApplicationController
  def create
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
  end
  
  private
  def reserve_params
    params.permit(:nickname, :email, :event_id)
  end
end