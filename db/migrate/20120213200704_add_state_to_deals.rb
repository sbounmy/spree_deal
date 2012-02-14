class AddStateToDeals < ActiveRecord::Migration
  def change
    add_column  :spree_deals, :state, :string
  end
end
