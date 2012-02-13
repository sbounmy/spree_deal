Spree::Creditcard.class_eval do
  def process!(payment, allow_capture=true)
    if Spree::Config[:auto_capture] && allow_capture
      purchase(payment.amount.to_f, payment)
    else
      authorize(payment.amount.to_f, payment)
    end
  end
end
