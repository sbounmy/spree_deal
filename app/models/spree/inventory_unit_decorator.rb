Spree::InventoryUnit.class_eval do
  scope :for_product, lambda { |product| where("spree_variants.product_id = ?", product.id).joins(:variant) }
end