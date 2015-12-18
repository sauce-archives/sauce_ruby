require 'spec_helper'
require 'sauce/capybara'
require 'sauce/connect'
#require 'capybara/server'

describe Sauce::Capybara do

  after :each do
    Sauce::Utilities::Connect.instance_variable_set(:@tunnel, false)
  end

  describe Sauce::Capybara::Driver do

    before :each do
      ::Capybara::Server.any_instance.stub(:boot).and_return(true)
    end

    let(:app) { proc { |env| [200, {}, ["Hello Sauce!"]]} }
    let(:driver) { Sauce::Capybara::Driver.new(app) }

    after :each do 
      Capybara.reset_sessions!
    end

    describe "#body" do
      context "With Capybara 1.x", :capybara_version => [1, "1.9.9"] do
        it "should not exist in version 2" do
          driver.should respond_to :base_body
        end
      end

      context "With Capybara 2.x", :capybara_version => [2, "2.9.9"] do
        it "should not exist" do
          driver.should_not respond_to :base_body
        end
      end
    end

    describe "#source" do
      context "With Capybara 1", :capybara_version => [1, "1.9.9"]  do
        it "should exist" do
          driver.should respond_to :base_source
        end
      end

      context "with Capybara 2.x", :capybara_version => [2, "2.9.9"] do
        it "should not exist" do
          driver.should_not respond_to :base_source
        end
      end
    end

    describe "#html" do
      context "With Capybara 1.x", :capybara_version => [1, "1.9.9"] do
        it "should not exist" do
          driver.should_not respond_to :base_html
        end
      end

      context "With Capybara 2.x", :capybara_version => [2, "2.9.9"] do
        it "should exist" do
          driver.should respond_to :base_html
        end
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

    describe '#rspec_browser' do
      let(:driver) { Sauce::Capybara::Driver.new(app) }

      before :each do
        Sauce::Selenium2.stub(:new).and_return(nil)
      end

      context "with no rspec driver" do

        before :each do
          Sauce.stub(:driver_pool).and_return({})
        end

        it "should return nil" do
          driver.rspec_browser.should be nil
        end

        it "should set the rspec_driver flag to false" do
          driver.rspec_browser
          driver.instance_variable_get(:@using_rspec_browser).should be_false
        end

      end

      context "with an rspec driver" do
        let(:mock_driver) {Object.new}
        before :each do
          Sauce.stub(:driver_pool).and_return({Thread.current.object_id => mock_driver})
        end

        it "should return the driver" do
          driver.rspec_browser.should be mock_driver
        end

        it "should set the rspec_driver flag to true" do
          driver.rspec_browser
          driver.instance_variable_get(:@using_rspec_browser).should be_true
        end
      end

      context "called after a driver_pool change" do

        context "with no driver present" do
          let(:mock_driver) {Object.new}

          before (:each) do
            Sauce.stub(:driver_pool).and_return(
                {Thread.current.object_id => mock_driver},
                {Thread.current.object_id => nil}
            )
          end

          it "should return nil" do
            driver.rspec_browser.should eq mock_driver
            driver.rspec_browser.should be nil
          end

          it "should set rspec_browser flag false" do
            driver.rspec_browser
            driver.rspec_browser
            driver.instance_variable_get(:@using_rspec_browser).should be_false
          end
        end
      end
    end

    describe '#browser' do
      let(:driver) { Sauce::Capybara::Driver.new(app) }

      before :each do
        # Stub out the selenium driver startup
        Sauce::Selenium2.stub(:new).and_return(nil)
      end

      context "when there is a driver in the driver pool" do
        let(:mock_browser) {Object.new}
        before :each do
          Sauce.driver_pool[Thread.current.object_id] = mock_browser
        end

        it "should use the driver_pools browser" do
          driver.browser.should eq mock_browser
        end
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

      context "with Capybara < 2.1", :capybara_version => [2, "2.0.9"] do

        it "should exist" do
          driver.respond_to?(:find).should be_true
        end

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

      context "with Capybara => 2.1", :capybara_version => ["2.1", "2.9.9"] do
        it "should not be aliased" do
          driver.respond_to?(:base_find).should be_false
        end

        it "should not be retried" do
          Sauce::Capybara::Driver.instance_variable_get(:@methods_to_retry).should_not include :find
        end
      end
    end

    describe "#find_css" do
      context "with Capybara < 2.1", :capybara_version => [0, "2.0.9"] do
        it "should not be aliased" do
          driver.respond_to?(:base_find_css).should be_false
        end

        it "should not be retried" do
          Sauce::Capybara::Driver.instance_variable_get(:@methods_to_retry).should_not include :find_css
        end
      end

      context "with Capybara >= 2.1", :capybara_version => ["2.1", "2.9.9"] do
        it "should be aliased" do
          driver.respond_to?(:base_find_css).should be_true
        end

        it "should be retried" do
          Sauce::Capybara::Driver.instance_variable_get(:@methods_to_retry).should include :find_css
        end
      end
    end

    describe "#find_xpath" do
      context "with Capybara < 2.1",  :capybara_version => [0, "2.0.9"] do
        it "should not be aliased" do
          driver.respond_to?(:base_find_xpath).should be_false
        end

        it "should not be retried" do
          Sauce::Capybara::Driver.instance_variable_get(:@methods_to_retry).should_not include :find_xpath
        end
      end

      context "with Capybara >= 2.1", :capybara_version => ["2.1", "2.9.9"] do
        it "should be aliased" do
          driver.respond_to?(:base_find_xpath).should be_true
        end

        it "should be retried" do
          Sauce::Capybara::Driver.instance_variable_get(:@methods_to_retry).should include :find_xpath
        end
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

  describe 'used without rspec hooks' do
    include Capybara::DSL
    
    before :all do
      app = proc { |env| [200, {}, ["Hello Sauce!"]]}
      Capybara.app = app
      Sauce.driver_pool[Thread.current.object_id] = nil
    end

    it "should use one of the Sauce Connect ports", :capybara_version => ["2.5.0", "2.9.9"], :js => true do
      reset_capybara(2.5)
      used_port = Capybara.current_session.server.port
      Sauce::Config::POTENTIAL_PORTS.should include used_port 
    end

    it "should use one of the Sauce Connect ports", :capybara_version => [2, "2.4.9"], :js => true do
      reset_capybara(2.0)
      used_port = Capybara.current_session.server.port
      Sauce::Config::POTENTIAL_PORTS.should include used_port 
    end

    it "should use one of the Sauce Connect ports", :capybara_version => ["1.0.9", "1.9.9"], :js => true do
      reset_capybara(1.1)
      used_port = Capybara.current_session.driver.rack_server.port
      Sauce::Config::POTENTIAL_PORTS.should include used_port 
    end

    it "should use one of the Sauce Connect ports", :capybara_version => ["1.0.0", "1.0.9"], :js => true do
      reset_capybara(1.0)
      used_port = Capybara.current_session.driver.rack_server.port
      Sauce::Config::POTENTIAL_PORTS.should include used_port 
    end

    describe "with start_local_application set false", :capybara_version => ["2.0.0", "2.9.9"] do
      before do
        @start_local_application = Sauce::Config.new[:start_local_application]
      end

      after do
        Sauce.config do |c|
          c[:start_local_application] = @start_local_application
        end
      end
      it "should not use Sauce Connect ports" do
        Sauce.config { |c| c[:start_local_application] = false }
        reset_capybara(2.0)
        Capybara.server_port.should eq nil
      end
    end
  end

  def reset_capybara(capy_version)
    Capybara.reset_sessions!

    Capybara.configure do |config|
      case capy_version
      when 1.0
        config.server_boot_timeout = 10
        config.prefer_visible_elements = true
        config.ignore_hidden_elements = false
      when 1.1
        config.server_boot_timeout = 10
        config.prefer_visible_elements = true
        config.automatic_reload = true
        config.ignore_hidden_elements = false
      when 2.0
        config.always_include_port = false
        config.match = :smart
        config.exact = false
        config.raise_server_errors = true
        config.visible_text_only = false
        config.automatic_reload = true
        config.ignore_hidden_elements = true
        config.server_port = nil
      when capy_version >= 2.5
        config.default_max_wait_time = 2
      end

      config.run_server = true
      config.server {|app, port| Capybara.run_default_server(app, port)}
      config.default_selector = :css
      config.default_wait_time = 2
      config.default_host = "http://www.example.com"

      Sauce::Capybara.configure_capybara
      Capybara.default_driver = :sauce
    end
  end
end