class ContactMailer < ApplicationMailer
  default from: "info@realtimesocial.jp"
  
  # administratorへ送信
  def mail_for_admin(contact) 
    @contact = contact
    mail(
      subject: "【Realtime Social】お問い合わせがありました。",
      to: "info@realtimesocial.jp"
    ) do |format|
      format.html
    end 
  end
  
  # お問い合わせ者へ自動送信
  def mail_for_user(contact) 
    @contact = contact
    mail(
      subject: "【Realtime Social】お問い合わせを受け付けました。",
      to: @contact.email
    ) do |format|
      format.text
    end 
  end
end
