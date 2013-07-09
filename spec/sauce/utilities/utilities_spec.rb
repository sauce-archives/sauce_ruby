require "spec_helper"
require "sauce/connect"

Sauce.config do |c|
  c[:start_tunnel] = false
end

describe "Sauce::Utilities::Connect" do

  before :each do
    @mock_tunnel = double()
  end

  after :each do
    Sauce::Utilities::Connect.instance_variable_set(:@tunnel, nil)
  end
  describe "##start" do
    it "should call Sauce Connect when included" do
      @mock_tunnel.stub(:connect).and_return true
      @mock_tunnel.stub(:wait_until_ready).and_return true
      Sauce::Connect.should_receive(:new).with(anything) {@mock_tunnel}
      Sauce::Utilities::Connect.start
    end

    it "should throw an exception when Sauce Connect is not included" do
      Object.should_receive(:require).with("sauce/connect").and_raise LoadError

      lambda {Sauce::Utilities::Connect.start}.should raise_error SystemExit
    end

    it "should connect the new tunnel" do
      @mock_tunnel.should_receive(:connect).with().and_return(true)
      @mock_tunnel.should_receive(:wait_until_ready).and_return(true)

      Sauce::Connect.stub(:new).with(anything).and_return @mock_tunnel

      Sauce::Utilities::Connect.start
    end

    it "should return the tunnel when done" do
      @mock_tunnel.stub(:connect).and_return true
      @mock_tunnel.stub(:wait_until_ready).and_return true
      Sauce::Connect.should_receive(:new).with(anything) {@mock_tunnel}
      tunnel = Sauce::Utilities::Connect.start
      tunnel.should be @mock_tunnel
    end

    it "only opens one tunnel" do
      @mock_tunnel.stub(:connect).and_return true
      @mock_tunnel.stub(:wait_until_ready).and_return true
      Sauce::Connect.should_receive(:new).with(anything) {@mock_tunnel}
      tunnel = Sauce::Utilities::Connect.start

      tunnel_2 = Sauce::Utilities::Connect.start

      tunnel.should be tunnel_2
    end
  end

  describe "#close" do
    it "makes the tunnel nil when terminated" do
      @mock_tunnel.stub(:connect).and_return true
      @mock_tunnel.stub(:wait_until_ready).and_return true
      @mock_tunnel.should_receive(:disconnect).and_return true
      Sauce::Connect.stub(:new).with(anything) {@mock_tunnel}
      Sauce::Utilities::Connect.start

      Sauce::Utilities::Connect.close
      Sauce::Utilities::Connect.instance_variable_get(:@tunnel).should be nil
    end

    it "calls disconnect" do
      @mock_tunnel.stub(:connect).and_return true
      @mock_tunnel.stub(:wait_until_ready).and_return true
      @mock_tunnel.should_receive(:disconnect).and_return true
      Sauce::Connect.stub(:new).with(anything) {@mock_tunnel}
      tunnel = Sauce::Utilities::Connect.start

      Sauce::Utilities::Connect.close
    end

    it "does not error if no tunnel exists" do
      Sauce::Utilities::Connect.close
    end
  end
end
