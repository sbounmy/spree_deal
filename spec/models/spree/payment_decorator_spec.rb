require 'spec_helper'

describe Spree::Payment do
  let(:order) { Factory(:order) }
  let(:deal) { Factory(:deal) }
  let(:product) { deal.product }
  let(:payment) { Factory(:payment, :order => order) }

  context "#process!" do
    context "order containing at least 1 deal" do
      before do
        deal
        order.add_variant(product.master, 1)
        payment
      end

      it "should process payment with allow_capture to false" do
        payment.source.should_receive(:process!).with(payment, false)
        payment.process!
      end

      it "creditcard should authorize" do
        payment.source.should_receive(:authorize).with(payment.amount.to_f, payment)
        payment.process!
      end
    end

    context "order containing at no deal" do
      before do
        Spree::Config.stub("[]").and_return(true)
        deal
        order.add_variant(Factory(:product).master, 1)
        payment
      end

      it "should process payment with allow_capture to true" do
        payment.source.should_receive(:process!).with(payment, true)
        payment.process!
      end

      it "creditcard should purchase" do
        payment.source.should_receive(:purchase).with(payment.amount.to_f, payment)
        payment.process!
      end
    end

  end

end
