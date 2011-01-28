require File.expand_path("../helper", __FILE__)

class TestSelenium < Test::Unit::TestCase
  def test_successful_connection_from_environment
    selenium = Sauce::Selenium.new(:job_name => "Sauce gem test suite: test_selenium.rb",
                                   :browser_url => "http://www.google.com/")
    selenium.start
    selenium.open "/"
    selenium.stop
  end
end
