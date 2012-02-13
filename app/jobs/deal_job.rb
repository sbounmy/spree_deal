module Spree
  class DealJob < Struct.new(:deal_id)
    def perform
      DealMailer.expiration_email(deal).deliver
    end

    def deal
      @deal ||= Deal.find(deal_id)
    end
  end
end