module Spree::Admin
  class DealsController < ResourceController
    def index
      respond_with(@collection) do |format|
        format.html
        format.json { render :json => json_data }
      end
    end

    def new
      @deal = Spree::Deal.new
    end
  end
end
