class PayMailer < ApplicationMailer
  default from: "noreply@example.com"
  
  # 支払い完了メール
  def mail_pay_complite(reserve)
    @reserve = reserve
    @event = Event.find(@reserve.event_id)
    mail(
      subject: "お支払いが予約が完了しました。",
      to: @reserve.email
    ) do |format|
      format.text
    end  
  end

end