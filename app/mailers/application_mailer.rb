# frozen_string_literal: true

class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch('EMAIL_NOTIFICATION_FROM') { 'invalid@invalid.com' }
  layout 'mailer'
end
