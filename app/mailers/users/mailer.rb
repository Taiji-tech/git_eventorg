class Users::Mailer < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers
  default template_path: 'devise/mailer'
  def confirmation_instructions(record, token, opts={})
    opts[:subject] = "【Realtime Social】メールアドレスの確認"
    super
  end
end