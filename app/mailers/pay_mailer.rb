class PayMailer < ApplicationMailer
  default from: "info@realtimesocial.jp"
  
  # 支払い完了メール
  def mail_pay_complite(reserve)
    @reserve = reserve
    @event = Event.find(@reserve.event_id)
    mail(
      subject: "【Realtime Social】イベント参加費のお支払いが完了しました！",
      to: @reserve.email
    ) do |format|
      format.text
    end  
  end
  
  # クレカ登録完了メール
  def mail_credit_registered(user) 
    @user = user
    mail(
      subject: "【Realtime Social】クレジットカードの登録が完了しました。",
      to: @user.email
    ) do |format|
      format.text
    end  
  end
  
  # クレカ変更完了メール
  def mail_credit_updated(user)
    @user = user
    mail(
      subject: "【Realtime Social】クレジットカードの情報が更新されました。",
      to: @user.email
    ) do |format|
      format.text
    end  
  end
  
  # 口座情報登録完了メール
  def mail_bank_registered(user)
    @user = user
    mail(
      subject: "【Realtime Social】銀行口座登録が完了しました。",
      to: @user.email
    ) do |format|
      format.text
    end  
  end  
  
  # 入金口座情報変更完了メール
  def mail_bank_updated(user)
    @user = user
    mail(
      subject: "【Realtime Social】銀行口座情報が更新されました。",
      to: @user.email
    ) do |format|
      format.text
    end  
  end
end