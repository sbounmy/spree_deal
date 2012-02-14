module Spree
  class Deals::ConfirmJob < Struct.new(:deal_id)
    def perform
      deal.orders.each do |order|
        DealMailer.confirmation_email(:deal => deal, :order => order).deliver
      end
    end

    def deal
      @deal ||= Deal.find(deal_id)
    end
  end
end