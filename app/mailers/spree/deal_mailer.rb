module Spree
  class DealMailer < ActionMailer::Base
    helper 'spree/base'
    default from: "from@example.com"

    def expiration_email(deal, resend=false)
      @deal = deal
      subject = (resend ? "[#{t(:resend).upcase}] " : "")
      subject += "[ALERT]#{Spree::Config[:site_name]} #{t('deal_mailer.expiration_email.subject')} ##{deal.id}"
      mail(:to => User.admin.collect(&:email),
      :subject => subject)
    end
  end
end