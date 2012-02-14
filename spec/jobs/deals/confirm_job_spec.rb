require 'spec_helper'

module Spree
  describe Deals::ConfirmJob do
    let(:deal) { Factory(:deal) }
    let(:order1) { Factory(:order) }
    let(:order2) { Factory(:order) }
    let(:order3) { Factory(:order) }
    let(:product) { deal.product }
    let(:admin) { Factory(:admin_user, :email => "admin@spree.com") }

    before do
      deal
      order1.add_variant(product.master, 2)
      order2.add_variant(product.master, 5)
      order3.add_variant(Factory(:product).master, 2)
    end

    describe "#perform" do
      it "sends email to customers" do
        [order1, order2, order3].each do |order|
          order.state = "confirm"
          order.next!
        end
        job = Deals::ConfirmJob.new(deal.id)
        expect { job.perform }.to change(ActionMailer::Base.deliveries, :count).by(2)
      end
    end

  end
end