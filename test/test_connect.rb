require File.expand_path("../helper", __FILE__)

class TestConnect < Test::Unit::TestCase
  context "Sauce Connect" do
    should "be running when ready" do
      connect = Sauce::Connect.new(:host => "saucelabs.com", :port => 80)
      assert_equal "uninitialized", connect.status
      connect.wait_until_ready
      assert_equal "running", connect.status 
      connect.status.should == "running"
      connect.disconnect
    end

    should "set error flag if things don't go well" do
      connect = Sauce::Connect.new(:host => "saucelabs.com", :port => 80, :username => 'fail')
      start = Time.now
      while Time.now-start < 20 && !connect.error
        sleep 1
      end

      assert connect.error
      connect.disconnect
    end
  end
end
