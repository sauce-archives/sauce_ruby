require 'test_helper'

require "sauce/capybara"
require "mocha/setup"

Sauce.config do |c|
  c[:browsers] = [
      ["Windows 7", "Firefox", "18"],
      ["Linux", "Firefox", "17"]
  ]
end

Capybara.default_driver = :sauce

class CapybaraTestCase < Sauce::TestCase
  include Capybara::DSL

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end

class CapybaraIntegrationTest < CapybaraTestCase

  # Called after every test method runs. Can be used to tear
  # down fixture information.

  def test_driver_is_from_the_driver_pool
    assert_equal Capybara.current_session.driver.browser, selenium
  end

  def test_capybara_does_not_create_a_new_driver
    ::Sauce::Selenium2.expects(:new).never
    visit "http://www.wikipedia.org"
  end
end