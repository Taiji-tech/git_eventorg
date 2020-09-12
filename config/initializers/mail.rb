# メール設定
if Rails.env.development?
  # mail送信設定される場合はコメントアウトを解除してください。  
  # ActionMailer::Base.delivery_method = :smtp
  # ActionMailer::Base.smtp_settings = {
  #   address: 'smtp.gmail.com',
  #   domain: 'gmail.com',
  #   port: 587,
  #   user_name: Rails.application.credentials.gmail[:address],
  #   password: Rails.application.credentials.gmail[:password],
  #   authentication: 'plain',
  #   enable_starttls_auto: true
  # }
elsif Rails.env.production?


else
  ActionMailer::Base.delivery_method = :test

end