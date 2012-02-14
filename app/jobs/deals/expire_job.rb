module Spree
  class Deals::ExpireJob < Struct.new(:deal_id)
    def perform
      deal.expire!
    end

    def deal
      @deal ||= Deal.find(deal_id)
    end
  end
end