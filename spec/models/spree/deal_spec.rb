require 'spec_helper'

describe Spree::Deal do
  it { should validate_presence_of :name }
  it { should validate_presence_of :product_id }
  it { should validate_presence_of :starts_at }
  it { should validate_presence_of :expires_at }
end
