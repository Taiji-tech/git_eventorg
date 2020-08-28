class UsersController < ApplicationController
  def show
    @nickname = current_user.nickname
  end
  
  # ユーザーのプロフィール設定
  def profile
    @events = current_user.events.page(params[:page]).per(5).order("start_date DESC")
  end
  
  def edit
    @user = User.find(current_user.id)
  end
  
  # ユーザー情報の更新
  def update
    @user = User.find(current_user.id)
    if @user.update(user_params)
      flash[:notice] = "ユーザー情報の編集が完了しました！"
      redirect_to user_edit_path
    else
      flash[:notice] = "編集に失敗しました。入力いただいた情報をご確認ください。"
      render :edit
    end
  end
  
  # パスワードの更新
  def updatePass
    @user = User.find(current_user.id)
    if @user.valid_password?(params[:user][:current_password])
      if @user.update(user_params)
        bypass_sign_in(@user)
        flash[:notice] = "ユーザー情報の編集が完了しました！"
        redirect_to user_edit_path
      else
        flash[:notice] = "編集に失敗しました。入力いただいた情報をご確認ください。"
        render :edit
      end
    else 
      flash[:notice] = "編集に失敗しました。入力いただいた情報をご確認ください。"
      render :edit
    end
  end
  
  
    private
      def user_params
        params.require(:user).permit(:nickname, :email, :password, :password_confirmation)
      end

  
end
