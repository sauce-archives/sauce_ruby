require File.join(File.dirname(__FILE__), "helper")

describe "The Sauce website", :type => :selenium do
  it "works" do
    selenium.open "/"
    page.is_text_present("Sauce Labs").should be_true
  end

  it "has a pricing page" do
    selenium.open "/pricing"
  end
end
