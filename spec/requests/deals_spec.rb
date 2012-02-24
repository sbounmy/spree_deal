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
    end

    scenario "customer can purchase it" do
      visit spree.deals_path
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

      visit spree.admin_deals_path
      click_link "Edit"
      within "ul.sidebar[data-hook='admin_deal_tabs']" do
        click_link "Orders"
      end
      page.should have_content("$20")
    end

    scenario "customer can't purchase it when deal is over" do
      Timecop.travel(2.months.from_now)
      Delayed::Worker.new.work_off
      visit spree.deals_path

      # list price
      page.should_not have_content("$40")
      # discount price
      page.should_not have_content("$10")
      # discount
      page.should_not have_content("-75%")
      page.should_not have_content("Hot deal !")
      # page.should have_content("200 needed for the deal to go live!")
      Timecop.return
    end

    scenario "cart should empty on complete checkout (deal_pending state)" do
      visit spree.deals_path
      click_link "Ror Mug Hot deal !"
      click_button "Add To Cart"

      complete_order
      find('#link-to-cart').find('a').text.should == "CART: (EMPTY)"
    end

    scenario "customer is able to track his deal" do
      visit spree.deals_path
      click_link "Ror Mug Hot deal !"
      click_button "Add To Cart"

      complete_order
      visit spree.order_path(Spree::Order.last)
      page.should have_content "Deal RoR Mug"
      page.should have_content "active"

      # deal expires
      Timecop.travel(2.months.from_now) do
        Delayed::Worker.new.work_off
        visit spree.order_path(Spree::Order.last)
        page.should have_content "pending"

        # deal confirmed
        Spree::Deal.last.confirm!
        visit spree.order_path(Spree::Order.last)
        page.should have_content "valid"
      end

    end
  end
end