require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'sauce/capybara'

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

    after :each do
      $sauce_tunnel = nil
    end
  end

  describe Sauce::Capybara::Driver do
    describe '#browser' do
      before :each do
        # Stub out the selenium driver startup
        Sauce::Selenium2.stub(:new).and_return(nil)
      end
      context 'when tunneling is disabled' do
        it 'should not call #connect_tunnel' do
          Sauce::Capybara.should_receive(:connect_tunnel).never
          Sauce.config do |c|
            c[:start_tunnel] = false
          end

          driver = Sauce::Capybara::Driver.new(nil)
          driver.browser
        end
      end
    end
    context 'with a mock app' do
      let(:app) { double('Mock App for Driver') }

      subject do
        Sauce::Capybara::Driver.new(app)
      end

      describe '#find' do
        let(:selector) { '#lol' }

        context 'with an environment override' do
          before :each do
            ENV['SAUCE_DISABLE_RETRY'] = '1'
          end

          it 'should not retry and raise the error' do
          subject.should_receive(:base_find).with(selector).and_raise(Selenium::WebDriver::Error::UnknownError)

          expect {
            subject.find(selector)
          }.to raise_error(Selenium::WebDriver::Error::UnknownError)
          end

          after :each do
            ENV['SAUCE_DISABLE_RETRY'] = nil
          end
        end

        it 'should route through handle_retry' do
          subject.should_receive(:base_find).with(selector) # BLECH
          subject.find(selector)
        end

        it 'should retry 3 times and then raise' do
          subject.should_receive(:base_find).with(selector).exactly(4).times.and_raise(Selenium::WebDriver::Error::UnknownError)

          expect {
            subject.find(selector)
          }.to raise_error(Selenium::WebDriver::Error::UnknownError)
        end
      end

      describe '#visit' do
        it 'should route through #handle_retry' do
          path = '/lol'
          subject.should_receive(:base_visit).with(path)
          subject.visit(path)
        end
      end

      describe '#current_url' do
        it 'should route through #handle_retry' do
          url = 'http://lol'
          subject.should_receive(:base_current_url).and_return(url)
          subject.current_url.should == url
        end
      end

    end
  end

  describe '#install_hooks' do
  end
end
