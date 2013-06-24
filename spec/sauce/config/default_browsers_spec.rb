require "rspec"

describe "Sauce::Config :browsers" do
  before :each do
    Sauce.clear_config
  end

  context "When unset" do
    it "defaults to the tutorial browsers" do
      tutorial_browsers = [
        ["Windows 8", "Internet Explorer", "10"],
        ["Windows 7", "Firefox", "20"],
        ["OS X 10.8", "Safari", "6"],
        ["Linux", "Chrome", nil]
      ]

      Sauce::Config.new[:browsers].should eq tutorial_browsers
    end
  end

  context "When set" do
    before :each do
      Sauce.clear_config

      Sauce.config do |config|
        config[:browsers] = [['TEST_OS', 'TEST_BROWSER', 'TEST_BROWSER_VERSION']]
      end
    end

    it 'should default the config to the first item' do
      c = Sauce::Config.new
      c.os.should == 'TEST_OS'
      c.browser.should == 'TEST_BROWSER'
      c.browser_version == 'TEST_BROWSER_VERSION'
    end

    it 'should return an Array of the (os, browser, version)' do
      c = Sauce::Config.new
      c[:os] = 'A'
      c[:browser] = 'B'
      c[:browser_version] = 'C'

      c.browsers.should == [['A', 'B', 'C']]
    end
  end
end