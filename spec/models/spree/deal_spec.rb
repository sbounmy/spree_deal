require 'spec_helper'

describe Spree::Deal do
  it { should validate_presence_of :name }
  it { should validate_presence_of :product_id }
  it { should validate_presence_of :starts_at }
  it { should validate_presence_of :expires_at }
  let(:deal) { Factory(:deal) }

  context "on create" do
    it "pushes a job to run at expires_at" do
      expect { deal }.to change(Delayed::Job, :count).by(1)
    end
  end
end
