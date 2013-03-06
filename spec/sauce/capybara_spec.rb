require 'spec_helper'
require 'sauce/capybara'
require 'sauce/connect'

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

    let(:app) { double('Mock App for Driver') }
    let(:driver) { Sauce::Capybara::Driver.new(app) }

    describe "#body", :capy_version => 1 do
      it "should exist" do
        driver.should respond_to :body
      end
    end

    describe "#source", :capy_version => 1 do
      it "should exist" do
        driver.should respond_to :source
      end
    end

    describe '#finish' do
      let(:browser) { double('Sauce::Selenium2 mock') }

      before :each do
        driver.instance_variable_set(:@browser, browser)
      end

      it 'should quit the @browser' do
        browser.should_receive(:quit)
        driver.finish!
      end

      it 'should nil out @browser' do
        browser.stub(:quit)
        driver.finish!
        expect(driver.instance_variable_get(:@browser)).to be_nil
      end
    end

    describe '#browser' do
      let(:driver) { Sauce::Capybara::Driver.new(app) }

      before :each do
        # Stub out the selenium driver startup
        Sauce::Selenium2.stub(:new).and_return(nil)
      end
      context 'when tunneling is disabled' do
        it 'should not call #connect_tunnel' do
          Sauce::Capybara.should_receive(:connect_tunnel).never
          Sauce.stub(:get_config) {{:start_tunnel => false}}

          driver.browser
        end
      end
    end

    describe '#find' do
      let(:selector) { '#lol' }

      context 'with an environment override' do
        before :each do
          ENV['SAUCE_DISABLE_RETRY'] = '1'
        end

        it 'should not retry and raise the error' do
          driver.should_receive(:base_find).with(selector).and_raise(Selenium::WebDriver::Error::UnknownError)

          expect {
            driver.find(selector)
          }.to raise_error(Selenium::WebDriver::Error::UnknownError)
        end

        after :each do
          ENV['SAUCE_DISABLE_RETRY'] = nil
        end
      end

      it 'should route through handle_retry' do
        driver.should_receive(:base_find).with(selector) # BLECH
        driver.find(selector)
      end

      it 'should retry 3 times and then raise' do
        driver.should_receive(:base_find).with(selector).exactly(4).times.and_raise(Selenium::WebDriver::Error::UnknownError)

        expect {
          driver.find(selector)
        }.to raise_error(Selenium::WebDriver::Error::UnknownError)
      end
    end

    describe '#visit' do
      it 'should route through #handle_retry' do
        path = '/lol'
        driver.should_receive(:base_visit).with(path)
        driver.visit(path)
      end
    end

    describe '#current_url' do
      it 'should route through #handle_retry' do
        url = 'http://lol'
        driver.should_receive(:base_current_url).and_return(url)
        driver.current_url.should == url
      end
    end

    describe '#within_frame' do
      it 'should route through #handle_retry and yield block' do
        driver.should_receive(:base_within_frame).and_yield
        driver.within_frame do
          "lol"
        end
      end
    end

  end

  describe '#install_hooks' do
  end
end
