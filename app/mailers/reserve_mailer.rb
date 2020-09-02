class ReserveMailer < ApplicationMailer
  
  # 予約完了メール（ユーザー登録あり）
  def mail_reserve_complite(reserve)
    @reserve = reserve
    @event = Event.find(@reserve.event_id)
    mail(
      subject: "予約が完了しました。",
      to: @reserve.email
    ) do |format|
      format.text
    end  
  end
  
  # 予約完了メール（ユーザー登録なし）
  
  
end
