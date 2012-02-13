module Spree
  class Deal < ActiveRecord::Base
    validates_presence_of :name, :product_id, :starts_at, :expires_at
    belongs_to :product
    delegate_belongs_to :product, :list_price, :price

    before_create :complete_orders

    scope :active, where("starts_at <= ? AND expires_at > ?", Time.now, Time.now)
    scope :for, lambda { |product| where(:product_id => product.try(:id)) }

    def percent
      product.deal_percent
    end

    def left_quantity
      minimum_quantity
    end

    def complete_orders
      # orders.each do |order|
      #   order.deal_complete
      # end
    end

    #TODO optimize this by sql join
    def orders
      Order.deal_pending.select { |order| order.products.collect(&:id).include?(product_id) }
    end

    handle_asynchronously :complete_orders, :run_at => Proc.new { |deal| deal.expires_at }
  end
end