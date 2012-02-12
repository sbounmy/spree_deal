class AddListPriceToVariants < ActiveRecord::Migration
  def change
    add_column  :spree_variants,  :list_price, :decimal, :precision => 8, :scale => 2
  end
end
