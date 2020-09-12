class PayMailer < ApplicationMailer
  default from: "noreply@example.com"
  
  # 支払い完了メール
  def mail_pay_complite(reserve)
    @reserve = reserve
    @event = Event.find(@reserve.event_id)
    mail(
      subject: "イベント参加費のお支払いが予約が完了しました。【" + @event.title + "】",
      to: @reserve.email
    ) do |format|
      format.text
    end  
  end

end