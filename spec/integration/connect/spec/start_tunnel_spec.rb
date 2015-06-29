require "spec_helper"

describe "Sauce::Config", :sauce => true do
  it "should start Connect when start_tunnel is set" do
    tunnel = Sauce::Utilities::Connect.tunnel
    tunnel.should_not be_nil
    tunnel.status.should eq "running"
  end
end