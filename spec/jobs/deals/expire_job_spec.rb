require 'spec_helper'

module Spree
  describe Deals::ExpireJob do
    let(:deal) { Factory(:deal) }
    let(:order) { Factory(:order) }
    let(:product) { deal.product }
    let(:admin) { Factory(:admin_user, :email => "admin@spree.com") }

    describe "#perform" do
      before do
        admin
      end
      it "sends an email to admins" do
        order.add_variant(product.master, 1)
        job = Deals::ExpireJob.new(deal.id)
        expect { job.perform }.to change(ActionMailer::Base.deliveries, :count).by(1)
      end
    end

  end
end