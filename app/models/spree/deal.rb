module Spree
  class Deal < ActiveRecord::Base
    validates_presence_of :name, :original_product_id, :starts_at, :expires_at
    validates_presence_of :product_id, :on => :update
    belongs_to :product, :dependent => :destroy
    delegate_belongs_to :product, :list_price, :price

    before_validation :set_original_product_id
    after_create :enqueue_expiration_job
    before_create :duplicate_original_product, :if => :new_product?

    after_save   :enqueue_start_job, :if => "starts_at_changed? and !active?"
    before_update :duplicate_original_product_and_destroy_old, :if => :new_product?
    attr_accessor :original_product_id

    scope :active, where(:state => "active")
    scope :for, lambda { |product| where(:product_id => product.try(:id)) }

    state_machine :initial => 'created', :use_transactions => false do
      event :expire do
        transition :from => 'active', :to => 'expired'
      end

      event :start do
        transition :from => 'created', :to => 'active', :if => "starts_at <= Time.now"
      end

      event :confirm do
        transition :from => 'expired', :to => 'complete'
      end

      event :void do
        transition :from => 'expired', :to => 'void'
      end

      after_transition :to => 'expired', :do => :notify_admin
      after_transition :to => 'complete', :do => :enqueue_confirm_job
    end

    def notify_admin
      DealMailer.expiration_email(self).deliver
    end

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

    def enqueue_expiration_job
      Delayed::Job.enqueue(Deals::ExpireJob.new(id), :run_at => expires_at)
    end

    def enqueue_start_job
      unless start
        Delayed::Job.enqueue(Deals::StartJob.new(id), :run_at => starts_at)
      end
    end

    def enqueue_confirm_job
      Delayed::Job.enqueue(Deals::ConfirmJob.new(id))
    end

    #TODO optimize this by sql join
    def orders
      @orders ||= Order.deal_pending.select { |order| order.inventory_units.collect(&:variant).collect(&:product_id).include?(product_id) }
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