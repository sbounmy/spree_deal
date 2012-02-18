Spree::CheckoutController.class_eval do
  private
  def after_deal_pending
    session[:order_id] = nil
  end
end
