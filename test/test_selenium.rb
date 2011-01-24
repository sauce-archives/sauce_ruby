require File.expand_path("../helper", __FILE__)

class TestSelenium < Test::Unit::TestCase
  context "The Sauce Selenium driver" do
    should "Connect successfully using credentials from the environment" do
      assert ENV['SAUCE_USERNAME'], "You haven't configured a Sauce OnDemand username. Please set $SAUCE_USERNAME"
      assert ENV['SAUCE_ACCESS_KEY'], "You haven't configured a Sauce OnDemand access key. Please set $SAUCE_ACCESS_KEY"
      selenium = Sauce::Selenium.new(:job_name => "Sauce gem test suite: test_selenium.rb",
                                     :browser_url => "http://www.google.com/")
      selenium.start
      selenium.open "/"
      selenium.stop
    end
  end
end
