require 'spec_helper'

describe Spree::Order do
  let(:order) { Factory(:order) }
  let(:deal) { Factory(:deal) }
  let(:product) { deal.product }

  context "#next" do
    context "when current state is confirm" do
      before { order.state = "confirm" }

      context "order has deal" do
        before do
          deal
          order.add_variant(product.master, 1)
        end

        it "should transition to deal_pending state" do
          order.next!
          order.state.should == "deal_pending"
        end
      end

      context "order has no deal" do
        before do
          deal
          order.add_variant(Factory(:product).master, 1)
        end

        it "should transition to complete state" do
          order.next!
          order.has_active_deal?.should be_false
          order.state.should == "complete"
        end
      end
    end
  end

  context "#has_active_deal?" do
    context "returns true" do
      it "when there are product with active deals" do
        deal
        order.add_variant(deal.product.master, 1)
        order.has_active_deal?.should be_true
      end

      it "when there are at least 1 product with active deals" do
        deal
        order.add_variant(Factory(:product).master, 1)
        order.add_variant(product.master, 1)
        order.has_active_deal?.should be_true
      end
    end

    context "returns false" do
      it "when there are product with no active deals" do
        deal.update_attributes!(:starts_at => 2.weeks.ago, :expires_at => 1.week.ago)
        order.add_variant(product.master, 1)
        order.has_active_deal?.should be_false
      end

      it "when there are product with no deals" do
        deal
        order.add_variant(Factory(:product).master, 1)
        order.has_active_deal?.should be_false
      end

    end
  end
end
