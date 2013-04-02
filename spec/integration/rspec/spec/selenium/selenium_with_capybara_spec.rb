require "rspec"
require "rspec/mocks"
require "spec_helper"
require "sauce/capybara"

class MyRackApp
  def self.call(env)
    [200, {}, ["Hello"]]
  end
end

Sauce.config do |c|
  c.browsers = [
      ["Windows 2008", "iexplore", "9"],
      ["Linux", "opera", 12]
  ]
end

Capybara.app = MyRackApp

describe "The Selenium Directory with Capybara", :js => true do

  include Capybara::DSL
  it "should get run on every defined browser", :js => true do
    visit "http://www.google.com"
  end

  it "should have the same driver as stock webdriver", :js => true do
    Capybara.current_session.driver.browser.should eq @selenium
  end

  it "should not create a new driver" do
    ::Sauce::Selenium2.should_not_receive(:new)
    visit "http://wwww.google.com"
  end
end
