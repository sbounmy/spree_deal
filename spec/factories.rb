Factory.define :deal, :class => Spree::Deal do |d|
  d.minimum_quantity 100
  d.sequence(:name) { |n| "deal_#{n}"}
  d.description "brand new deal !"
  d.starts_at Date.yesterday
  d.expires_at  1.week.from_now
  d.product_id { Factory(:product).id }
end