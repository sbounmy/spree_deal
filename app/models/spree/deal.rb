class Spree::Deal < ActiveRecord::Base
  validates_presence_of :name, :product_id, :starts_at, :expires_at
  belongs_to :product
  delegate_belongs_to :product, :list_price, :price

  before_create :complete_orders

  def percent
    product.deal_percent
  end

  def left_quantity
    minimum_quantity
  end

  def complete_orders

  end
  handle_asynchronously :complete_orders, :run_at => Proc.new { |deal| deal.expires_at }
end
