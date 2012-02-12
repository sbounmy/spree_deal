Spree::Variant.class_eval do
  def list_price
    read_attribute(:list_price) || price
  end
end