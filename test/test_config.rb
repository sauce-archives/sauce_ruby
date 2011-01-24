require 'helper'

class TestConfig < Test::Unit::TestCase
  context "A new Config" do
    should "Generate a reasonable browser string from the environment" do
      preserved_env = {}
      Sauce::Config::ENVIRONMENT_VARIABLES.each do |key|
        preserved_env[key] = ENV[key] if ENV[key]
      end
      begin

        ENV['SAUCE_USERNAME'] = "test_user"
        ENV['SAUCE_ACCESS_KEY'] = "test_access"
        ENV['SAUCE_OS'] = "Linux"
        ENV['SAUCE_BROWSER'] = "firefox"
        ENV['SAUCE_BROWSER_VERSION'] = "3."

        config = Sauce::Config.new
        assert_equal "{\"name\":\"Unnamed Ruby job\",\"access-key\":\"test_access\",\"os\":\"Linux\",\"username\":\"test_user\",\"browser-version\":\"3.\",\"browser\":\"firefox\"}", config.to_browser_string
      ensure
        Sauce::Config::ENVIRONMENT_VARIABLES.each do |key|
          ENV[key] = preserved_env[key] if preserved_env[key]
        end
      end
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

    should "gracefully degrade the browsers field" do
      Sauce.config {|c|}
      config = Sauce::Config.new
      config.os = "A"
      config.browser = "B"
      config.browser_version = "C"

      assert_equal [["A", "B", "C"]], config.browsers
    end

    should "Let you set and query boolean flags" do
      config = Sauce::Config.new
      config.foo = true
      assert config.foo?
    end
  end

  context "The Sauce.config method" do
    should "Allow you to set a default OS" do
      Sauce.config {|c| c.os = "TEST_OS" }

      config = Sauce::Config.new
      assert_equal "TEST_OS", config.os
    end

    should "Be callable twice" do
      Sauce.config {|c| c.os = "A"}
      assert_equal "A", Sauce::Config.new.os
      Sauce.config {|c|}
      assert_not_equal "A", Sauce::Config.new.os
    end

    should "not retain config after being called again" do
      Sauce.config {|c|}
      assert_not_equal [["Windows 2003", "firefox", "3.6."]], Sauce::Config.new.browsers
    end
  end
end
