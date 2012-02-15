class CreateSpreeDeals < ActiveRecord::Migration
  def change
    create_table :spree_deals do |t|
      t.string      :name
      t.text        :description
      t.integer     :minimum_quantity
      t.references  :product
      t.datetime  :starts_at
      t.datetime  :expires_at
      t.timestamps
    end
  end
end
