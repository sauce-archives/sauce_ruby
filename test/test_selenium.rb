require 'helper'

class TestSelenium < Test::Unit::TestCase
  context "The Sauce Selenium driver" do
    should "Connect successfully using credentials from the environment" do
      assert ENV['SAUCE_USERNAME'], "You haven't configured a Sauce OnDemand username. Please set $SAUCE_USERNAME"
      assert ENV['SAUCE_USERNAME'], "You haven't configured a Sauce OnDemand access key. Please set $SAUCE_ACCESS_KEY"
      selenium = Sauce::Selenium.new()
      selenium.start
      selenium.open "/"
      selenium.stop
    end
  end
end
