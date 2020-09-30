class EventMailer < ApplicationMailer
  default from: "noreply@realtimesocial.jp"
  
  # イベント作成時
  def mail_event_create(event)
    @event = event
    @user = User.find(@event.user_id)
    mail(
      subject: "【Realtime Socail】イベントを作成しました！",
      to: @user.email
    ) do |format|
      format.text
    end 
  end
  
  # イベント削除時
  def mail_event_destroy(event) 
    @event = event
    @user = User.find(@event.user_id)
    mail(
      subject: "【Realtime Socail】イベントを中止にしました。",
      to: @user.email
    ) do |format|
      format.text
    end 
  end
  
end