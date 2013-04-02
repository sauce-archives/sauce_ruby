require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe "DriverPool" do

  it "should be a hash" do
    Sauce.driver_pool.should be_an_instance_of Hash
  end
end