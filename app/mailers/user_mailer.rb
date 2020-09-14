class UserMailer < ApplicationMailer
  default from: "noreply@example.com"
  
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
  def mail_user_editinfo(before_user, user)
    @before_user = before_user
    @user = user
    
    # e-mailの変更がされていない場合
    if @before_user.email == @user.email
      mail(
        subject: "【Realtime Socail】ユーザー情報が変更されました！",
        to: @user.email
      ) do |format|
        format.text
      end
    else
      mail(
        subject: "【Realtime Socail】ユーザー情報が変更されました！",
        to: @user.email, 
        cc: @before_user.email
      ) do |format|
        format.text
      end
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