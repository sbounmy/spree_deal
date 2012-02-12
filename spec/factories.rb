Factory.define :deal, :class => Spree::Deal do |d|
  d.minimum_quantity 100
  d.sequence(:name) { |n| "deal_#{n}"}
  d.description "brand new deal !"
  d.starts_at Date.yesterday
  d.expires_at  1.week.from_now
end

# Factory.define :create_deal_adjustment, :class => Spree::Deal::Actions::CreateDealAdjustment do |c|
#   c.calculator { |a| a.association(:per_item_calculator, :calculable_id => a.object_id, :calculable_type => a.class.to_s) }
# end
#
# Factory.define :per_item_calculator, :class => Spree::Calculator::PerDealItem do |p|
#   p.preferred_amount -10
#   p.product_id { |a| a.association(:product).id }
# end
#
# Factory.define :deal_product, :class => Spree::Deal::Rules::DealProduct do |d|
#   d.products { |p| [p.association(:product)] }
# end
