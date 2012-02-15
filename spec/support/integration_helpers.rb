module IntegrationHelpers
  def complete_order
    address = Factory(:address, :state => Spree::State.first)

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
    click_button "Place Order"
  end
end

RSpec.configure do |c|
  c.include IntegrationHelpers, :type => :request
end


