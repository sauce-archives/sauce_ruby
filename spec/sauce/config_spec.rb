require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'sauce/config'

describe Sauce::Config do
  let(:c) do
    config = Sauce::Config.new
    config.stub(:silence_warnings).and_return(true)
    config
  end
  before :each do
    Sauce.clear_config
  end

  describe '#[]' do
    it "should return nil for options that don't exist" do
      c = Sauce::Config.new
      c[:undefined].should be_nil
    end

    it "should return defaults if they haven't been set" do
      c = Sauce::Config.new
      c[:browser].should == Sauce::Config::DEFAULT_OPTIONS[:browser]
    end

    it "should return the value set in the constructor" do
      c = Sauce::Config.new(:myoption => 1337)
      c[:myoption].should == 1337
    end
  end

  describe "#[]=" do
    it "should allow setting arbitrary options" do
      c[:setting_option] = 1337
      c[:setting_option].should == 1337
    end

    it "should allow using strings for keys" do
      c["my-option"] = 1337
      c["my-option"].should == 1337
    end
  end

  describe 'deprecate method_missing' do
    it 'should warn when accessing an old style method' do
      c.stub(:silence_warnings).and_return(false)
      c.should_receive(:warn).with(anything)
      c.capture_traffic
    end
  end

  describe '#host' do
    it 'should return ondemand.saucelabs.com by default' do
      c.host.should == 'ondemand.saucelabs.com'
    end
  end

  describe '#os' do
    it 'should return the value set in the config block' do
      Sauce.config do |config|
        config[:os] = 'TEST_OS'
      end

      c = Sauce::Config.new
      c[:os].should == 'TEST_OS'
    end
  end

  describe '#to_browser_string' do
    before :each do
      @original_env = {}
      Sauce::Config::ENVIRONMENT_VARIABLES.each do |key|
        @original_env[key] = ENV[key] if ENV[key]
      end
    end

    it 'should create a browser string when running under the Jenkins plugin' do
      browsers_string = "[{\"os\":\"LINUX\",\"browser\":\"opera\",\"url\":\"sauce-ondemand:?os=Linux&browser=opera&browser-version=12\",\"browser-version\":\"12\"}]"
      browsers = JSON.parse(browsers_string)
      ENV['SAUCE_ONDEMAND_BROWSERS'] = browsers_string

      config = Sauce::Config.new
      result = JSON.parse(config.to_browser_string)

      result['os'].should == browsers.first['os']
      result['browser'].should == browsers.first['browser']
      result['browser-version'].should == browsers.first['browser-version']
    end

    it 'should create a browser string from the environment' do
      ENV['SAUCE_USERNAME'] = "test_user"
      ENV['SAUCE_ACCESS_KEY'] = "test_access"
      ENV['SAUCE_OS'] = "Linux"
      ENV['SAUCE_BROWSER'] = "firefox"
      ENV['SAUCE_BROWSER_VERSION'] = "3."

      config = Sauce::Config.new
      browser_data = JSON.parse(config.to_browser_string)
      browser_data.should == {'name' => 'Unnamed Ruby job',
                              'access-key' => 'test_access',
                              'os' => 'Linux',
                              'username' => 'test_user',
                              'browser-version' => '3.',
                              'browser' => 'firefox'}
    end

    it 'should create a browser string from the environment set by the jenkins plugin' do
      ENV['SAUCE_USERNAME'] = 'test_user'
      ENV['SAUCE_ACCESS_KEY'] = 'test_access'
      ENV['SAUCE_OS'] = 'Linux'
      ENV['SAUCE_BROWSER'] = 'firefox'
      ENV['SAUCE_BROWSER_VERSION'] = '3.'
      ENV['SAUCE_JOB_NAME'] = 'Named Ruby Job'

      config = Sauce::Config.new
      browser_data = JSON.parse(config.to_browser_string)
      browser_data.should == {'name' => 'Named Ruby Job',
                              'access-key' => 'test_access',
                              'os' => 'Linux',
                              'username' => 'test_user',
                              'browser-version' => '3.',
                              'browser' => 'firefox'}

    end

    it 'should create a browser string from parameters' do
      config = Sauce::Config.new(:username => 'test_user',
                                 :access_key => 'test_access',
                                 :os => 'Linux',
                                 :browser => 'firefox',
                                 :browser_version => '3.')

      browser_data = JSON.parse(config.to_browser_string)
      browser_data.should == {'name' => 'Unnamed Ruby job',
                              'access-key' => 'test_access',
                              'os' => 'Linux',
                              'username' => 'test_user',
                              'browser-version' => '3.',
                              'browser' => 'firefox'}
    end

    it 'should create a browser string with optional parameters' do
      config = Sauce::Config.new(:username => "test_user", :access_key => "test_access",
                                :os => "Linux", :browser => "firefox", :browser_version => "3.",
                                :"user-extensions-url" => "testing")
      browser_data = JSON.parse(config.to_browser_string)
      browser_data.should == {'name' => 'Unnamed Ruby job',
                              'access-key' => 'test_access',
                              'os' => 'Linux',
                              'username' => 'test_user',
                              'browser-version' => '3.',
                              'browser' => 'firefox',
                              'user-extensions-url' => 'testing'}
    end

    it 'should create a browser string with optional parameters as underscored symbols' do
      config = Sauce::Config.new(:username => "test_user", :access_key => "test_access",
                                :os => "Linux", :browser => "firefox", :browser_version => "3.",
                                :user_extensions_url => "testing")
      browser_data = JSON.parse(config.to_browser_string)
      browser_data.should == {'name' => 'Unnamed Ruby job',
                              'access-key' => 'test_access',
                              'os' => 'Linux',
                              'username' => 'test_user',
                              'browser-version' => '3.',
                              'browser' => 'firefox',
                              'user-extensions-url' => 'testing'}
    end

    after :each do
        Sauce::Config::ENVIRONMENT_VARIABLES.each do |key|
          ENV[key] = @original_env[key]
        end
    end
  end

  describe '#to_desired_capabilities' do
    context 'with custom sauce options' do
      context 'max-duration' do
        subject do
          Sauce::Config.new(:'max-duration' => 600).to_desired_capabilities
        end

        it { should have_key :'max-duration' }
      end
    end

    context 'platforms' do
      it 'should refer to Windows 2003 as WINDOWS' do
        config = Sauce::Config.new(:os => "Windows 2003")
        config.to_desired_capabilities[:platform].should == 'WINDOWS'
      end

      it 'should refer to Windows 2008 as VISTA' do
        config = Sauce::Config.new(:os => "Windows 2008")
        config.to_desired_capabilities[:platform].should == 'VISTA'
      end
    end

    context 'client_version' do
      let(:config) {Sauce::Config.new()}

      it 'should include the Ruby engine' do
        config.to_desired_capabilities[:client_version].should include RUBY_ENGINE
      end

      it "should include the ruby platform" do
        config.to_desired_capabilities[:client_version].should include RUBY_PLATFORM
      end

      it "should include the ruby version" do
        config.to_desired_capabilities[:client_version].should include RUBY_VERSION
      end

      it "should include the gem version" do
        config.to_desired_capabilities[:client_version].should include Sauce.version
      end

      it "should include a bracketed array of tools in use" do
        config.to_desired_capabilities[:client_version].should include config.tools.to_s
      end
    end

    describe "#config.add_tool" do
      let(:config) {Sauce::Config.new()}

      it "should add a tool to the list" do
        config.add_tool :rspec
        config.tools.should include :rspec
      end
    end
  end

  context 'configuring Sauce' do
    it 'should make foo? methods for set boolean values' do
      c.some_option = true
      c.some_option?.should be true
    end

    describe 'browsers=' do
      it 'should default the config to the first item' do
        Sauce.config do |config|
          config[:browsers] = [['TEST_OS', 'TEST_BROWSER', 'TEST_BROWSER_VERSION']]
        end

        c = Sauce::Config.new
        c.os.should == 'TEST_OS'
        c.browser.should == 'TEST_BROWSER'
        c.browser_version == 'TEST_BROWSER_VERSION'
      end
    end

    describe 'browsers' do
      it 'should return an Array of the (os, browser, version)' do
        c.os = 'A'
        c.browser = 'B'
        c.browser_version = 'C'

        c.browsers.should == [['A', 'B', 'C']]
      end
    end

    it 'should allow overrides as constructor options' do
      Sauce.config do |config|
        config[:browsers] = [['OS1', 'BROWSER1', 'BROWSER_VERSION1']]
      end

      c = Sauce::Config.new(:os => 'OS2', :browser => 'BROWSER2',
                            :browser_version => 'BROWSER_VERSION2')
      c.os.should == 'OS2'
      c.browser.should == 'BROWSER2'
      c.browser_version.should == 'BROWSER_VERSION2'
    end
  end
end

describe Sauce do

  # Ensure any doubles are removed to stop other tests choking
  after :all do
    Sauce.clear_config
  end

  describe '#get_config' do
    context 'when #config has never been called' do
      # See: <https://github.com/sauce-labs/sauce_ruby/issues/59>
      before :each do
        # This is kind of hack-ish, but the best way I can think to properly
        # prevent this class variable from existing
        Sauce.instance_variable_set(:@cfg, nil)
      end

      it 'should return a newly created Sauce::Config' do
        dummy_config = double('Sauce::Config')
        Sauce::Config.should_receive(:new).and_return(dummy_config)
        Sauce.get_config.should_not be nil
      end
    end

    context 'when config has been called' do
      before :each do
        Sauce.clear_config
        Sauce.config do |c|
          c[:some_setting] = true
        end
      end
      it 'should return the same config with the same configuration' do
        Sauce.get_config.should_not be nil
        Sauce.get_config[:some_setting].should be true
      end
    end
  end

  describe '#clear_config' do
    it 'should reset the config object' do
      c = Sauce.get_config
      Sauce.clear_config
      c.should_not equal(Sauce.get_config)
    end
  end
end
