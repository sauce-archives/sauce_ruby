require "test/unit"
require File.join(File.dirname(__FILE__), "helper")

class TestSaucelabs < Sauce::TestCase
  def test_basic_functionality
    selenium.get "http://www.saucelabs.com"
    assert selenium.page_source.include?("Sauce Labs")
  end

  def test_pricing_page
    selenium.navigate.to "http://www.saucelabs.com/pricing"
    assert selenium.page_source.include?("$")
  end
end
