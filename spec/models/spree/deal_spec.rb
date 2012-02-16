require 'spec_helper'

describe Spree::Deal do
  it { should validate_presence_of :name }
  it { should validate_presence_of :product_id }
  it { should validate_presence_of :starts_at }
  it { should validate_presence_of :expires_at }
  let(:deal) { Factory(:deal) }
  let(:order) { Factory(:order) }
  let(:product) { deal.product }

  context "on create" do
    it "pushes a job to run at expires_at" do
      expect { deal }.to change(Delayed::Job, :count).by(1)
    end

    it "create a new product if product_id has no deal" do
      original = Factory(:product)
      @deal = Spree::Deal.new(Factory.attributes_for(:deal).merge(:product_id => original.id))
      expect { @deal.save! }.to change(Spree::Product, :count).by(1)
      @deal.product.should_not be_nil
      @deal.product.should_not == original
    end

    it "is not valid with invalid duplicate_product_id" do
      @deal = Spree::Deal.new(Factory.attributes_for(:deal).merge(:product_id => 0))
      expect { @deal.save }.to_not change(Spree::Product, :count)
      @deal.new_record?.should be_true
      @deal.product.should be_nil
    end

    it "set product prefix sku and name" do
      original = Factory(:product)
      @deal = Factory(:deal, :product_id => original.id)
      @deal.save!
      @deal.product.name.should =~ /Deal Product/
      @deal.product.sku.should =~ /Deal /
    end

    context "when starts_at in the future" do
      let(:deal_attrs) { Factory.attributes_for(:deal, :starts_at => 1.day.from_now, :product_id => Factory(:product).id) }
      it "pushes a second job" do
        expect { Spree::Deal.create(deal_attrs) }.to change(Delayed::Job, :count).by(2)
      end

      it "starts the deal when only when it is reached" do
        @deal = Spree::Deal.new(deal_attrs)
        expect do
          @deal.save!
          Timecop.freeze(@deal.starts_at + 1.minutes) { Delayed::Worker.new.work_off }
          @deal.reload
        end.to change(@deal, :state).from("created").to("active")
      end

      it "starts the deal when only when it is reached" do
        @deal = Spree::Deal.new(deal_attrs)
        expect do
          init_date = @deal.starts_at
          @deal.save!
          @deal.update_attributes :starts_at => init_date + 1.day
          Timecop.freeze(init_date) { Delayed::Worker.new.work_off }
          @deal.reload.state.should == "created"
          Timecop.freeze(@deal.starts_at) { Delayed::Worker.new.work_off }
          @deal.reload
        end.to change(@deal, :state).from("created").to("active")
      end

    end
  end

  describe "on update" do
    it "destroy product deal when product_id changes" do
      pending "should we allow this ?"
      deal and product
      other_product = Factory(:product)
      expect { deal.update_attributes(:product_id => other_product.id) }.should_not change(Spree::Product, :count)
      deal.product.should_not == product
    end

    it "does nothing when same product_id" do
      deal and product
      expect { deal.update_attributes(:product_id => product.id) }.should_not change(Spree::Product, :count)
      deal.product.should == product
    end
  end

  describe "on complete" do
    it "push a confirmjob to the queue" do
      deal.expire!
      Delayed::Worker.new.work_off
      expect { deal.confirm! }.to change(Delayed::Job, :count).by(1)
    end
  end
end
