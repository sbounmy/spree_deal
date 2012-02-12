require 'spec_helper'

feature "deals feature", :js => true do
  background do
    # creates a default shipping method which is required for checkout
    Factory(:bogus_payment_method, :environment => 'test')
    # creates a check payment method so we don't need to worry about cc details
    Factory(:payment_method)

    Factory(:shipping_method, :zone => Spree::Zone.find_by_name('North America'))
    user = Factory(:admin_user)
    @mug = Factory(:product, :name => "RoR Mug", :price => "40")
    @bag = Factory(:product, :name => "RoR Bag", :price => "20")
    sign_in_as!(user)

    visit spree.new_admin_deal_path
  end
  let!(:address) { Factory(:address, :state => Spree::State.first) }

  def complete_order
    click_link "Checkout"

    str_addr = "bill_address"
    select "United States", :from => "order_#{str_addr}_attributes_country_id"
    ['firstname', 'lastname', 'address1', 'city', 'zipcode', 'phone'].each do |field|
      fill_in "order_#{str_addr}_attributes_#{field}", :with => "#{address.send(field)}"
    end
    select "#{address.state.name}", :from => "order_#{str_addr}_attributes_state_id"
    check "order_use_billing"
    click_button "Save and Continue"
    click_button "Save and Continue"

    choose('Credit Card')
    fill_in "card_number", :with => "4111111111111111"
    fill_in "card_code", :with => "123"
    click_button "Save and Continue"
  end

  context "there is a valid deal" do
    before do
      visit spree.new_admin_deal_path
      fill_in "Name", :with => "Ror Mug Hot deal !"
      fill_in "Starts at", :with => Date.yesterday.to_s
      fill_in "Expires at", :with => 1.week.from_now.to_s

      fill_in "Description", :with => "This is your last chance to get it at this price !"
      fill_in "Minimum Quantity", :with => 200

      page.execute_script %Q{$('input[name$="deal[product_id]"]').val('#{@mug.id}').focus();}

      click_button "Create"
      page.should have_content('Deal "Ror Mug Hot deal !" has been successfully created!')

      click_link "Edit"
      fill_in "List Price", :with => "40"
      fill_in "Price", :with => "10"
      click_button "Update"

      visit spree.deals_path
    end

    scenario "customer can purchase it" do
      # list price
      page.should have_content("$40")
      # discount price
      page.should have_content("$10")
      # discount
      page.should have_content("-75%")

      click_link "Ror Mug Hot deal !"

      page.should have_content("$40")
      # discount price
      page.should have_content("$10")
      # discount
      page.should have_content("-75%")

      page.should have_content("Hot deal !")
      # page.should have_content("200 needed for the deal to go live!")

      click_button "Add To Cart"

      within("#subtotal") do
        page.should have_content("$10.00")
      end
      within("#line_items") do
        within("td[data-hook='cart_item_price']") do
          page.should have_content("$10")
        end
        within("td[data-hook='cart_item_total']") do
          page.should have_content("$10")
        end
      end
      complete_order
      Spree::Order.last.item_total.should == 10
      Spree::Order.last.adjustments.promotion.map(&:amount).sum.to_f.should == 0
    end
  end
end