require File.join(File.dirname(__FILE__), "helper")

class TestSaucelabs < Sauce::TestCase
  def test_basic_functionality
    selenium.open "/"
    assert page.is_text_present("Sauce Labs")
  end

  def test_pricing_page
    selenium.open "/pricing"
    assert page.is_text_present("$")
  end
end
