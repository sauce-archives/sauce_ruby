require "rubygems"
require "bundler/setup"
require "test/unit"
require "sauce"

Sauce.config do |c|
  c[:browsers] = [
      ["Windows 7", "Firefox", "18"]
  ]
end

class IntegrationTest < Sauce::TestCase

  # Called before every test method runs. Can be used
  # to set up fixture information.
  def setup
    # Do nothing
  end

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def teardown

  end

  def test_testunit_is_set_in_sauce_config
    capabilities = Sauce.get_config.to_desired_capabilities
    assert_includes capabilities[:client_version], "Test::Unit"
  end
end