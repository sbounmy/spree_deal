require 'spec_helper'

describe Spree::DealJob do
  let(:deal) { Factory(:deal) }
  let(:order) { Factory(:order) }
  let(:product) { deal.product }

  describe "#perform" do

    it "set order's line_item.deal_id to allow tracking" do
      order.add_variant(product.master, 1)
      job = Spree::DealJob.new(deal.id)
      job.perform
      # # expect { deal.complete_orders! }.to change { order.line_items.collect(&:deal_id).compact }.from([]).to([deal.id])
      # Timecop.travel(deal.expires_at + 1.minutes) { Delayed::Worker.new.work_off }
      # deal.complete_orders!
    end
  end

end