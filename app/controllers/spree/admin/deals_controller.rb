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

    def confirm
      @deal = Spree::Deal.find(params[:id])
      flash.notice = t("deal.complete") if @deal.confirm
      redirect_to admin_deals_path
    end
  end
end
