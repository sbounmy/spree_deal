class Spree::Deal < ActiveRecord::Base
  validates_presence_of :name, :product_id, :starts_at, :expires_at
  belongs_to :product
end
