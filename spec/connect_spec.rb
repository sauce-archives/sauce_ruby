require File.expand_path(File.dirname(__FILE__) + '/spec_helper')


describe Sauce::Capybara do
  describe '#connect_tunnel' do
    before :each do
      $sauce_tunnel = nil
    end

    it 'should not do anything if the sauce tunnel exists' do
      $sauce_tunnel = 1337
      Sauce::Capybara.connect_tunnel.should == 1337
    end

    it 'should connect if the tunnel is not connected' do
      pending 'Sauce::Connect#connect must be implemented'
      connector = double()
      connector.should_receive(:wait_until_ready)
      Sauce::Connect.should_receive(:new).and_return(connector)

      Sauce::Capybara.connect_tunnel
    end

    after :each do
      $sauce_tunnel = nil
    end
  end
end
