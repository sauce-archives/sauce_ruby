require 'helper'

class TestConfig < Test::Unit::TestCase
  context "A new Config" do
    should "Generate a reasonable browser string from the environment" do
      ENV['SAUCE_USERNAME'] = "test_user"
      ENV['SAUCE_ACCESS_KEY'] = "test_access"
      ENV['SAUCE_OS'] = "Linux"
      ENV['SAUCE_BROWSER'] = "firefox"
      ENV['SAUCE_BROWSER_VERSION'] = "3."

      config = Sauce::Config.new
      assert_equal "{\"name\":\"Unnamed Ruby job\",\"access-key\":\"test_access\",\"os\":\"Linux\",\"username\":\"test_user\",\"browser-version\":\"3.\",\"browser\":\"firefox\"}", config.to_browser_string
    end

    should "Generate a browser string from parameters" do
      config = Sauce::Config.new(:username => "test_user", :access_key => "test_access",
                                 :os => "Linux", :browser => "firefox", :browser_version => "3.")
      assert_equal "{\"name\":\"Unnamed Ruby job\",\"access-key\":\"test_access\",\"os\":\"Linux\",\"username\":\"test_user\",\"browser-version\":\"3.\",\"browser\":\"firefox\"}", config.to_browser_string
    end

    should "Respond to convenience accessors" do
      config = Sauce::Config.new
      assert_equal "saucelabs.com", config.host
    end
  end
end
