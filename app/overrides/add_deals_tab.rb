include Spree::UrlHelpers
include Spree::Admin::NavigationHelper

Deface::Override.new :name => "add_deals_tab", :insert_bottom => "ul[data-hook='admin_tabs']", :text => %q{<%= tab(:deals) %>}, :virtual_path => "spree/layouts/admin"