Deface::Override.new :name => "cart_form", :replace_contents => "#product-price div", :partial => "spree/deals/cart_form", :virtual_path => "spree/products/_cart_form"
Deface::Override.new :name => "products_list_item_price", :replace => "[itemprop='price']", :partial => "spree/deals/cart_form", :virtual_path => "spree/shared/_products"

