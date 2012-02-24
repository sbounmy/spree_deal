Deface::Override.new :name => "cart_form", :replace => "[data-hook='account_my_orders'] tbody code[erb-loud]:contains('t(order.state).titleize')", :text => %q{<%= link_to(t(order.state).titleize, order_inventory_units_path(order)) -%>}, :virtual_path => "spree/users/show"

Deface::Override.new :name => "order_details_header", :insert_before => "#line-items tr[data-hook='order_details_line_items_headers'] th.price", :text => "<th class='price'><%= t(:state) %></th>", :virtual_path => "spree/shared/_order_details"

Deface::Override.new :name => "order_details", :insert_after => "[data-hook='order_item_description']", :partial => "spree/deals/order_details", :virtual_path => "spree/shared/_order_details"