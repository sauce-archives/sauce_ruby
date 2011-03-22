require File.expand_path("../helper", __FILE__)

class TestSauceTestCase < Sauce::TestCase
  self.selenium_flags = {:trustAllSSLCertificates => false}
  self.sauce_config = {:browser_url => "https://cacert.org"}

  def test_turning_off_trustAllSSLCertificates
    selenium.set_timeout("5000")
    assert_raise Selenium::Client::CommandError do
      selenium.open("https://cacert.org")
    end
  end
end
