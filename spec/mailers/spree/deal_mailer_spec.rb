require "spec_helper"

describe Spree::DealMailer do
  let(:deal) { Factory(:deal) }
  let(:order) { Factory(:order) }
  let(:product) { deal.product }
  let(:admin) { Factory(:admin_user, :email => "admin@spree.com") }

  describe "#expiration_email" do
    let(:email) { Spree::DealMailer.expiration_email(deal).deliver }
    before do
      admin
      order.state = "confirm"
      order.add_variant(product.master, 1)
      order.next!

      order2 = Factory(:order)
      order2.add_variant(product.master, 3)
      order2.state = "confirm"
      order2.next!
    end

    it "sends an email to admins" do
      email.to.should == [admin.email]
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "shows correct information with insufisant orders" do
      email.encoded.should =~ /Deal is not valid with 4 \/ 100/
    end

    it "shows correct information with suffisant orders" do
      deal.update_attribute :minimum_quantity, 3
      email.encoded.should =~ /Deal is valid with 4 \/ 3/
    end
  end

  describe "#confirmation_email" do
    let(:customer) { order.user }
    let(:email) { Spree::DealMailer.confirmation_email(:order => order, :deal => deal).deliver }

    before do
      order.add_variant(product.master, 3)
      order.state = "confirm"
      order.next!
      ActionMailer::Base.deliveries = []
    end

    it "sends an email to customer" do
      email.to.should == [order.email]
      ActionMailer::Base.deliveries.should_not be_empty
    end

    it "shows deal complete information" do
      email.encoded.should =~ /The deal #{deal.name} is complete !/
      email.encoded.should =~ /Product: #{deal.product.name}/
      email.encoded.should =~ /Quantity: 3/
    end
  end

end
