require File.join(File.dirname(File.expand_path(File.dirname(__FILE__))), "test", "helper")

describe "The login form", :type => :selenium do
  it "exists" do
    selenium.open "/"
  end
end
