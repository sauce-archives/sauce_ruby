require "test/unit"
require File.join(File.dirname(__FILE__), "helper")

class TestSaucelabs2 < Sauce::TestCase
  def test_basic_functionality_two
    selenium.get "http://www.saucelabs.com"
    assert page.is_text_present("Sauce Labs")
  end
end

