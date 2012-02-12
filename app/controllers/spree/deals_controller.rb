module Spree
  class DealsController < BaseController
    respond_to :html
    HTTP_REFERER_REGEXP = /^https?:\/\/[^\/]+\/t\/([a-z0-9\-\/]+)$/

    def index
      @deals = Deal.all
    end

    def show
      @deal = Deal.find(params[:id])

      @product = @deal.product
      #TODO DRY this, comes from ProductsController#show
      @variants = Variant.active.includes([:option_values, :images]).where(:product_id => @deal.product_id)
      @product_properties = ProductProperty.includes(:property).where(:product_id => @deal.product_id)

      referer = request.env['HTTP_REFERER']

      if referer && referer.match(HTTP_REFERER_REGEXP)
        @taxon = Taxon.find_by_permalink($1)
      end

      respond_with(@deal)
    end
  end
end