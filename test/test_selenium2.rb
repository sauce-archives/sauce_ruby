require File.expand_path("../helper", __FILE__)

class TestSelenium2 < Test::Unit::TestCase
  def test_successful_connection_from_environment
    selenium = Sauce::Selenium2.new(:job_name => "Sauce gem test suite: test_selenium2.rb")
    selenium.navigate.to "http://www.example.com/"
    selenium.quit
  end
end
