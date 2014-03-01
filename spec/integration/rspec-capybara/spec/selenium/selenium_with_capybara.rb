require "spec_helper"

describe "The Selenium Directory with Capybara", :js => true do
  it "should have the same driver as stock webdriver", :js => true do
    Capybara.current_session.driver.browser.should eq @selenium
  end

  it "should not create a new driver" do
    ::Sauce::Selenium2.should_not_receive(:new)
    visit "http://wwww.google.com"
  end
end