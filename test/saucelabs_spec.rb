require 'helper'

# This should go in a test helper
Sauce.config do |config|
  config.browsers = [
    ["Windows 2003", "firefox", "3.6."],
    ["Windows 2003", "safariproxy", "5."]
  ]
end

describe "The Sauce website", :type => :selenium do
  it "works" do
    page.open "/"
    page.is_text_present("Sauce Labs").should be_true
  end

  it "has a pricing page" do
    browser.open "/pricing"
  end
end
