module Spree
  class Deal < ActiveRecord::Base
    validates_presence_of :name, :original_product_id, :starts_at, :expires_at
    validates_presence_of :product_id, :on => :update
    belongs_to :product, :dependent => :destroy
    delegate_belongs_to :product, :list_price, :price

    before_create :enqueue_job
    before_create :duplicate_original_product

    before_update :duplicate_original_product_and_destroy_old, :if => "original_product_id != product_id"
    attr_accessor :original_product_id

    scope :active, where("starts_at <= ? AND expires_at > ?", Time.now, Time.now)
    scope :for, lambda { |product| where(:product_id => product.try(:id)) }

    def percent
      product.deal_percent
    end

    def left_quantity
      minimum_quantity
    end

    def enqueue_job
      Delayed::Job.enqueue(DealJob.new(id), :run_at => expires_at)
    end

    #TODO optimize this by sql join
    def orders
      @orders ||= Order.deal_pending.select { |order| order.products.collect(&:id).include?(product_id) }
    end

    def order_ids
      orders.collect(&:id)
    end

    def duplicate_original_product
      self.product_id = Product.find(original_product_id).duplicate.id
    rescue
      false
    end

    def duplicate_original_product_and_destroy_old
      product.destroy
      duplicate_original_product
    end
  end
end