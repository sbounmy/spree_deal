Spree::Product.class_eval do
  delegate_belongs_to :master, :list_price=, :list_price

  def deal_percent
    (100 - (price * 100 / list_price)) *-1
  end

  def deal_amount
    list_price - price
  end
end
