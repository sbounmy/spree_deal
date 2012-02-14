module Spree
  class Deals::StartJob < Struct.new(:deal_id)
    def perform
      deal.start
    end

    def deal
      @deal ||= Deal.find(deal_id)
    end
  end
end