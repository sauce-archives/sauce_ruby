require File.expand_path("../helper", __FILE__)

class TestConfig < Test::Unit::TestCase
  def test_generates_reasonable_browser_string_from_envrionment
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
        ENV[key] = preserved_env[key]
      end
    end
  end

  def test_generates_browser_string_from_parameters
    config = Sauce::Config.new(:username => "test_user", :access_key => "test_access",
                               :os => "Linux", :browser => "firefox", :browser_version => "3.")
    assert_equal "{\"name\":\"Unnamed Ruby job\",\"access-key\":\"test_access\",\"os\":\"Linux\",\"username\":\"test_user\",\"browser-version\":\"3.\",\"browser\":\"firefox\"}", config.to_browser_string
  end

  def test_convenience_accessors
    config = Sauce::Config.new
    assert_equal "saucelabs.com", config.host
  end

  def test_gracefully_degrades_browsers_field
    Sauce.config {|c|}
    config = Sauce::Config.new
    config.os = "A"
    config.browser = "B"
    config.browser_version = "C"

    assert_equal [["A", "B", "C"]], config.browsers
  end

  def test_boolean_flags
    config = Sauce::Config.new
    config.foo = true
    assert config.foo?
  end

  def test_sauce_config_default_os
    Sauce.config {|c| c.os = "TEST_OS" }
    begin
      config = Sauce::Config.new
      assert_equal "TEST_OS", config.os
    ensure
      Sauce.config {|c|}
    end
  end

  def test_can_call_sauce_config_twice
    Sauce.config {|c| c.os = "A"}
    assert_equal "A", Sauce::Config.new.os
    Sauce.config {|c|}
    assert_not_equal "A", Sauce::Config.new.os
  end

  def test_clears_config
    Sauce.config {|c|}
    assert_not_equal [["Windows 2003", "firefox", "3.6."]], Sauce::Config.new.browsers
  end
end
