Spree::Payment.class_eval do
  def process!
    if payment_method && payment_method.source_required?
      if source
        if !processing? && source.respond_to?(:process!)
          started_processing!
          source.process!(self, !order.contains_deal?) # source is responsible for updating the payment state when it's done processing
        end
      else
        raise Core::GatewayError.new(I18n.t(:payment_processing_failed))
      end
    end
  end
end
