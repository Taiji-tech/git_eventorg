class UserMailer < ApplicationMailer
  default from: "noreply@realtimesocial.jp"
  
#   ユーザー登録完了時
  def mail_user_registered(user)
    @user = user
    mail(
      subject: "【Realtime Socail】ユーザー登録が完了しました！",
      to: @user.email
    ) do |format|
      format.text
    end 
  end
  
#   ユーザー情報変更時
  def mail_user_editinfo_to_newuser(before_user, user)
    @before_user = before_user
    @user = user
    mail(
      subject: "【Realtime Socail】ユーザー情報が変更されました！",
      to: @user.email
    ) do |format|
      format.text
    end
  end
  
  def mail_user_editinfo_to_olduser(before_user, user)
    @before_user = before_user
    @user = user
    mail(
      subject: "【Realtime Socail】ユーザー情報が変更されました！",
      to: @before_user.email
    ) do |format|
      format.text
    end
  end  
  
#   パスワード変更時
  def mail_user_editpass(user)
    @user = user
    mail(
      subject: "【Realtime Socail】パスワードが変更されました！",
      to: @user.email
    ) do |format|
      format.text
    end 
  end
end