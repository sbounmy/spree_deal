module Spree
  # clearing states defined in core order.rb
  Order.state_machines.clear

  Order.class_eval do

    scope :deal_pending, where(:state => "deal_pending")

    # Additional state 'pending', other are copy paste from core/app/models/spree/order.rb
    Spree::Order.state_machines[:state] = StateMachine::Machine.new(Spree::Order, :initial => 'cart', :use_transactions => false) do

      event :next do
        transition :from => 'cart',     :to => 'address'
        transition :from => 'address',  :to => 'delivery'
        transition :from => 'delivery', :to => 'payment', :if => :payment_required?
        transition :from => 'delivery', :to => 'complete'
        transition :from => 'confirm',  :to => 'complete'

        # note: some payment methods will not support a confirm step
        transition :from => 'payment',  :to => 'confirm',
        :if => Proc.new { |order| order.payment_method && order.payment_method.payment_profiles_supported? }

        transition :from => 'payment', :to => 'complete'
      end
      event :cancel do
        transition :to => 'canceled', :if => :allow_cancel?
      end
      event :return do
        transition :to => 'returned', :from => 'awaiting_return'
      end
      event :resume do
        transition :to => 'resumed', :from => 'canceled', :if => :allow_resume?
      end
      event :authorize_return do
        transition :to => 'awaiting_return'
      end
      event :deal_pending do
        transition :to => 'deal_pending', :from => 'complete'
      end

      before_transition :to => 'complete' do |order|
        begin
          order.process_payments!
        rescue Core::GatewayError
          !!Spree::Config[:allow_checkout_on_gateway_error]
        end
      end

      before_transition :to => ['delivery'] do |order|
        order.shipments.each { |s| s.destroy unless s.shipping_method.available_to_order?(order) }
      end

      after_transition :to => 'complete', :do => :finalize!
      after_transition :to => 'complete', :do => :deal_pending!, :if => :has_active_deal?

      after_transition :to => 'delivery', :do => :create_tax_charge!
      after_transition :to => 'payment',  :do => :create_shipment!
      after_transition :to => 'resumed',  :do => :after_resume
      after_transition :to => 'canceled', :do => :after_cancel
    end

    def has_active_deal?
      Deal.active.where(:product_id => products.collect(&:id)).exists?
    end
  end
end