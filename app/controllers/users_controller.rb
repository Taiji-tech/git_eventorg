class UsersController < ApplicationController
  def show
    @nickname = current_user.nickname
  end
  
  # ユーザーのプロフィール設定
  def profile
    @events = current_user.events.page(params[:page]).per(5).order("start DESC")
    
  end
  
  def edit
    @user = User.find(current_user.id)
  end
  
  def update
    @user = User.find(current_user.id)
    if @user.update(users_params)
      flash[:notice] = "ユーザー情報の編集が完了しました！"
      redirect_to user_edit_path
    else
      flash[:notice] = "編集に失敗しました。入力いただいた情報をご確認ください。"
      render :edit
    end
  end
  
  
end
