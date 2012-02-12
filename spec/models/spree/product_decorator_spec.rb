require 'spec_helper'

describe Spree::Product do
  context "#list_price" do
    it "returns correct deal price / amount" do
      product = Factory(:product, :price => 70, :list_price => 100)
      product.list_price.should == 100
      product.price.should == 70
      product.deal_percent.to_f.should == -30
      product.deal_amount.to_f.should == 30
    end

    it "should not freakout without list_price" do
      product = Factory(:product, :price => 70)
      product.list_price.should == 70
      product.price.should == 70
      product.deal_percent.to_f.should == 0
      product.deal_amount.to_f.should == 0
    end
  end
end
