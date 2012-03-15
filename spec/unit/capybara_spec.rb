require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')


describe Sauce::Capybara do
  describe '#connect_tunnel' do
    before :each do
      $sauce_tunnel = nil
    end

    let(:connector) do
      connector = double()
      connector.should_receive(:connect)
      connector.should_receive(:wait_until_ready)
      connector
    end

    it 'should not do anything if the sauce tunnel exists' do
      $sauce_tunnel = 1337
      Sauce::Capybara.connect_tunnel.should == 1337
    end

    it 'should connect if the tunnel is not connected' do
      Sauce::Connect.should_receive(:new).and_return(connector)

      Sauce::Capybara.connect_tunnel
    end

    it 'should pass the quiet option to Sauce::Connect' do
      Sauce::Connect.should_receive(:new).with(
                    hash_including(:quiet => true)).and_return(connector)
      Sauce::Capybara.connect_tunnel(:quiet => true)
    end

    it "should pass Capybara.app_host's hostname as the host" do
      Capybara.should_receive(:app_host).and_return('http://localhost:4567/')
      Sauce::Connect.should_receive(:new).with(
                    hash_including(:host => 'localhost')).and_return(connector)
      Sauce::Capybara.connect_tunnel
    end

    it "should pass Capybara.app_host's port as the port" do
      Capybara.should_receive(:app_host).and_return('http://localhost:4567/')
      Sauce::Connect.should_receive(:new).with(
                    hash_including(:port => 4567)).and_return(connector)
      Sauce::Capybara.connect_tunnel
    end

    it "should pass Capybara.app_host's hostname as the domain" do
      Capybara.should_receive(:app_host).and_return('http://localhost:4567/')
      Sauce::Connect.should_receive(:new).with(
                    hash_including(:domain => 'localhost')).and_return(connector)
      Sauce::Capybara.connect_tunnel
    end


    after :each do
      $sauce_tunnel = nil
    end
  end
end
