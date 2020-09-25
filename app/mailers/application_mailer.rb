class ApplicationMailer < ActionMailer::Base
  add_template_helper(ApplicationHelper)
  default from: "info@realtimesocial.jp"
  layout 'mailer'
end
