class ReserveMailer < ApplicationMailer
  default from: "noreply@realtimesocial.jp"
  
  
  # 予約完了メール
  def mail_reserve_complite(reserve)
    @reserve = reserve
    @event = Event.find(@reserve.event_id)
    mail(
      subject: "【Realtime Social】イベントのご予約が完了しました！",
      to: @reserve.email
    ) do |format|
      format.text
    end  
  end
  
   # 支払い完了メール
  def mail_pay_complite(reserve)
    @reserve = reserve
    @event = Event.find(@reserve.event_id)
    mail(
      subject: "【Realtime Social】イベント参加費のお支払いが予約が完了しました！",
      to: @reserve.email
    ) do |format|
      format.text
    end  
  end
  
  # キャンセルメール
  def mail_cancel_complite(reserve)
    @reserve = reserve
    @event = Event.find(@reserve.event_id)
    mail(
      subject: "【Realtime Social】イベントをキャンセルしました。",
      to: @reserve.email
    ) do |format|
      format.text
    end  
  end
  
  # イベント削除時
  def mail_event_destroy_for_user(reserve) 
    @reserve = reserve
    @event = Event.find(@reserve.event_id)
    mail(
      subject: "【Realtime Socail】イベントが中止となりました。",
      to: @reserve.email
    ) do |format|
      format.text
    end 
  end
end
