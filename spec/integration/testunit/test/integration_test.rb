require 'test_helper'

Sauce.config do |c|
  c[:browsers] = [
      ["Windows 7", "Firefox", "18"]
  ]
  c[:sauce_connect_4_executable] = ENV["SAUCE_CONNECT_4_EXECUTABLE"]
end

class IntegrationTest < Sauce::TestCase

  def test_testunit_is_set_in_sauce_config
    capabilities = Sauce.get_config.to_desired_capabilities
    assert_includes capabilities[:client_version], "Test::Unit"
  end

  def test_rspec_is_not_set_in_sauce_config
    capabilities = Sauce.get_config.to_desired_capabilities
    assert_not_includes capabilities[:client_version], "Rspec"
  end
end