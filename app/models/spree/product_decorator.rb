Spree::Product.class_eval do
  has_one :deal
  has_one :active_deal, :conditions => ["spree_deals.state = 'active'"], :class_name => "Deal"
  delegate_belongs_to :master, :list_price=, :list_price

  def deal_percent
    (100 - (price * 100 / list_price)) *-1
  end

  def deal_amount
    list_price - price
  end

  def duplicate(options={})
    prefix = options[:prefix] || "COPY OF "
    p = self.dup
    p.name = prefix + self.name
    p.deleted_at = nil
    p.created_at = p.updated_at = nil
    p.taxons = self.taxons

    p.product_properties = self.product_properties.map { |q| r = q.dup; r.created_at = r.updated_at = nil; r }

    image_dup = lambda { |i| j = i.dup; j.attachment = i.attachment.clone; j }
    p.images = self.images.map { |i| image_dup.call i }

    master = Spree::Variant.find_by_product_id_and_is_master(self.id, true)
    variant = master.dup
    variant.sku = prefix + master.sku
    variant.deleted_at = nil
    variant.images = master.images.map { |i| image_dup.call i }
    p.master = variant

    if self.has_variants?
      # don't dup the actual variants, just the characterising types
      p.option_types = self.option_types
    else
    end
    # allow site to do some customization
    p.send(:duplicate_extra, self) if p.respond_to?(:duplicate_extra)
    p.save!
    p
  end
end
