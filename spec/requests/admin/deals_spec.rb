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
    fill_in "Name", :with => "Ror Mug Hot deal !"
    fill_in "Starts at", :with => Date.yesterday.to_s
    fill_in "Expires at", :with => 1.week.from_now.to_s

    fill_in "Description", :with => "This is your last chance to get it at this price !"
    fill_in "Minimum Quantity", :with => 200
    fill_in "Preferred amount", :with => -30

    page.execute_script %Q{$('input[name$="[calculator_attributes][product_id]"]').val('#{@mug.id}').focus();}

    click_button "Create"
    page.should have_content('Deal "Ror Mug Hot deal !" has been successfully created!')
  end

  scenario "admin can edit deal without errors" do
    click_link "Edit"
    click_button "Create"
    page.should have_content('Deal "Ror Mug Hot deal !" has been successfully updated!')
  end
end
