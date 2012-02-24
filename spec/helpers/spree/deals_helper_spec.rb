require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the Spree::DealsHelper. For example:
#
# describe Spree::DealsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe Spree::DealsHelper do
  let(:unit) { Factory(:inventory_unit) }
  let(:deal) { Factory(:deal, :product => unit.product) }
  describe "t_unit_state" do
    context "with deal product unit" do
      it "returns state pending when deal is expired" do
        deal.expire!
        unit.stub!(:state).and_return("backordered")
        t_unit_state(unit).should == "pending"
        unit.stub!(:state).and_return("sold")
        t_unit_state(unit).should == "pending"
      end

      it "returns state pending when deal is complete" do
        deal.expire!
        deal.confirm!
        unit.stub!(:state).and_return("backordered")
        t_unit_state(unit).should == "valid"
        unit.stub!(:state).and_return("sold")
        t_unit_state(unit).should == "ready"
      end

      it "returns state void when deal is void" do
        deal.expire!
        deal.void!
        unit.stub!(:state).and_return("backordered")
        t_unit_state(unit).should == "void"
        unit.stub!(:state).and_return("sold")
        t_unit_state(unit).should == "void"
      end

      it "returns active when deal is still active" do
        deal
        unit.stub!(:state).and_return("backordered")
        t_unit_state(unit).should == "active"
        unit.stub!(:state).and_return("sold")
        t_unit_state(unit).should == "active"
      end
    end

    context "with regular product" do
      it "returns state pending when deal is complete" do
        unit.stub!(:state).and_return("backordered")
        t_unit_state(unit).should == "backordered"
        unit.stub!(:state).and_return("sold")
        t_unit_state(unit).should == "ready"
        unit.stub!(:state).and_return("shipped")
        t_unit_state(unit).should == "shipped"
      end
    end
  end
end
