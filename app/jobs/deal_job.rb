module Spree
  class DealJob < Struct.new(:deal_id)
    def perform
      deal.orders.each do |order|
        order.deal_complete
      end
    end

    def deal
      @deal ||= Deal.find(deal_id)
    end
  end
end