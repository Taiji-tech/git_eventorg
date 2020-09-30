class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: 'noreply@realtimesocial.jp'
  layout 'mailer'
end
