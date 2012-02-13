module Spree
  class Deal < ActiveRecord::Base
    validates_presence_of :name, :original_product_id, :starts_at, :expires_at
    validates_presence_of :product_id, :on => :update
    belongs_to :product, :dependent => :destroy
    delegate_belongs_to :product, :list_price, :price

    before_validation :set_original_product_id
    before_create :enqueue_job
    before_create :duplicate_original_product, :if => :new_product?

    before_update :duplicate_original_product_and_destroy_old, :if => :new_product?
    attr_accessor :original_product_id

    scope :active, where("starts_at <= ? AND expires_at > ?", Time.now.to_s(:db), Time.now.to_s(:db))
    scope :for, lambda { |product| where(:product_id => product.try(:id)) }

    def percent
      product.deal_percent
    end

    def met?
      count_quantity >= minimum_quantity
    end

    def count_quantity
      @count_quantity ||= InventoryUnit.where(:variant_id => product.variants_including_master_ids).count
    end

    def left_quantity
      minimum_quantity - count_quantity
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

    def set_original_product_id
      self.original_product_id = original_product_id.nil? ? product_id : original_product_id
    end

    def duplicate_original_product
      self.product_id = Product.find(original_product_id).duplicate.id
      self.original_product_id = nil
    rescue
      false
    end

    def new_product?
      original_product_id && original_product_id != product_id
    end

    def duplicate_original_product_and_destroy_old
      product.destroy
      duplicate_original_product
    end
  end
end