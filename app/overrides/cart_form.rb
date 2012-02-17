Deface::Override.new :name => "cart_form", :insert_bottom => "[data-hook='product_price']", :partial => "spree/deals/cart_form", :virtual_path => "spree/products/_cart_form"
Deface::Override.new :name => "products_list_item_price", :replace => "[itemprop='price']", :partial => "spree/deals/product_price", :virtual_path => "spree/shared/_products"

