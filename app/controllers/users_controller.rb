class UsersController < ApplicationController
  before_action :authenticate_user!, only: [:show, :profile, :edit, :update, :updatePass] 
  after_action :store_location
  
  def show
    @nickname = current_user.nickname
  end
  
  # ユーザーのプロフィール設定
  def profile
    @events = current_user.events.page(params[:page]).per(5).order("start_date DESC")
    @reserves = Reserve.where(email: current_user.email)
  end
  
  def edit
    @user = User.find(current_user.id)
  end
  
  # ユーザー情報の更新
  def update
    @user = User.find(current_user.id)
    if @user.valid_password?(params[:user][:current_password])
      if @user.update(user_params)
        flash[:notice] = "ユーザー情報の編集が完了しました！"
        redirect_to user_edit_path
      else
        render "shared/errorDetail"
      end
    else 
      render "inputError.js"
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
        render "shared/errorDetail"
      end
    else 
      render "inputError.js"
    end
  end
  
  
    private
      def user_params
        params.require(:user).permit(:nickname, :email, :password, :password_confirmation)
      end

  
end
