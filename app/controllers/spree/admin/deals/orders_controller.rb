module Spree
  module Admin
    class Deals::OrdersController < BaseController
      def index
        @search = Order.metasearch(params[:search])
        @deal = Deal.find(params[:deal_id])
        @orders = @deal.orders
      end
    end
  end
end