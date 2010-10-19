require 'helper'

describe "saucelabs.com", :type => :selenium do
  it "works" do
    page.open "/"
    page.is_text_present("Sauce Labs").should be_true
  end
end
