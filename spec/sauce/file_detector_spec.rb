require "spec_helper"

describe Sauce::Selenium2 do
  describe "#file_detector" do
    it "should return the path of files when they exist" do
      Selenium::WebDriver::Remote::Bridge.any_instance.stub(:create_session).and_return({})
      Selenium::WebDriver::Remote::Bridge.any_instance.stub(:session_id).and_return("FSDSDFSDF")

      path = __FILE__

      client = Sauce::Selenium2.new()
      bridge = client.driver.instance_variable_get(:@bridge)
      bridge.file_detector.call([path]).should eq path
    end
  end
end