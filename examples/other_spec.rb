require File.join(File.dirname(__FILE__), "helper")

describe "The login form", :type => :selenium do
  it "exists" do
    selenium.open "/"
  end
end
