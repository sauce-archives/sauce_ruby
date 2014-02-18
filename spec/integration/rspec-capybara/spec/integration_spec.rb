require "spec_helper"

describe "Capybara examples", :js => true, :sauce => true, :type => :feature do
  it "should not create a new driver" do
    ::Sauce::Selenium2.should_not_receive(:new)
    visit "http://wwww.google.com"
  end

  it "should get access to a Capybara Session object" do
      page.should be_a_kind_of Capybara::Session
      visit "http://www.google.com"
  end

  it "should have the same driver as stock webdriver" do
    Capybara.current_session.driver.browser.should eq @selenium
  end
end