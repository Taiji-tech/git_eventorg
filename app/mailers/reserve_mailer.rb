class ReserveMailer < ApplicationMailer
  default from: "noreply@example.com"
  
  
  # 予約完了メール
  def mail_reserve_complite(reserve)
    @reserve = reserve
    @event = Event.find(@reserve.event_id)
    mail(
      subject: "イベントのご予約が完了しました！【" + @event.title + "】",
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
      subject: "イベントをキャンセルしました。【" + @event.title + "】",
      to: @reserve.email
    ) do |format|
      format.text
    end  
  end
end
