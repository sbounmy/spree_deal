require 'spec_helper'

describe Spree::Deal do
  it { should validate_presence_of :name }
  it { should validate_presence_of :original_product_id }
  it { should validate_presence_of :starts_at }
  it { should validate_presence_of :expires_at }
  let(:deal) { Factory(:deal) }
  let(:order) { Factory(:order) }
  let(:product) { deal.product }

  context "on create" do
    it "pushes a job to run at expires_at" do
      expect { deal }.to change(Delayed::Job, :count).by(1)
    end

    it "create a new product with duplicate_product_id" do
      original = Factory(:product)
      @deal = Spree::Deal.new(Factory.attributes_for(:deal).merge(:original_product_id => original.id))
      expect { @deal.save! }.to change(Spree::Product, :count).by(1)
      @deal.product.should_not be_nil
      @deal.product.should_not == original
    end

    it "is not valid with invalid duplicate_product_id" do
      original = Factory(:product)
      @deal = Spree::Deal.new(Factory.attributes_for(:deal).merge(:original_product_id => 0))
      expect { @deal.save }.to_not change(Spree::Product, :count)
      @deal.new_record?.should be_true
      @deal.product.should be_nil
    end
  end

  describe "on update" do
    it "destroy product deal when original_product_id changes" do
      deal and product
      other_product = Factory(:product)
      expect { deal.update_attributes(:original_product_id => other_product.id) }.should_not change(Spree::Product, :count)
      deal.product.should_not == product
    end

    it "does nothing when same original_product_id" do
      deal and product
      expect { deal.update_attributes(:original_product_id => product.id) }.should_not change(Spree::Product, :count)
      deal.product.should == product
    end
  end
  describe "#complete_orders" do

    it "set order's line_item.deal_id to allow tracking" do
      order.add_variant(product.master, 1)
      # expect { deal.complete_orders! }.to change { order.line_items.collect(&:deal_id).compact }.from([]).to([deal.id])
      Timecop.travel(deal.expires_at + 1.minutes) { Delayed::Worker.new.work_off }
      # deal.complete_orders!
    end
  end
end
