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
  
  # ユーザー情報の表示
  def edit
    @user = User.find(current_user.id)
  end
  
  # ユーザー情報の更新
  def update
    @user = User.find(current_user.id)
    @before_user = @user
    if @user.valid_password?(params[:user][:current_password])
      if @user.update(user_params)
        if @before_user.email == @user.email
          UserMailer.mail_user_editinfo_to_newuser(@before_user, @user).deliver_now
        else
          UserMailer.mail_user_editinfo_to_newuser(@before_user, @user).deliver_now
          UserMailer.mail_user_editinfo_to_olduser(@before_user, @user).deliver_now
        end
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
        UserMailer.mail_user_editpass(@user).deliver_now
        flash[:notice] = "パスワードの変更が完了しました！"
        redirect_to user_edit_path
      else
        render "shared/errorDetail"
      end
    else 
      render "inputError.js"
    end
  end
  
  # パスワード忘れ時の再設定
  def resetPass
    user = User.find_by(email: create_params[:email])
    user&.send_reset_password_instructions
    render json: {}
  end
  
    private
      def user_params
        params.require(:user).permit(:nickname, :email, :password, :password_confirmation)
      end
      
      def create_params
        params.require(:user).permit(:email)
      end

  
end
