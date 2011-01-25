require File.expand_path("../helper", __FILE__)

class TestConnect < Test::Unit::TestCase
  def test_running_when_ready
    connect = Sauce::Connect.new(:host => "saucelabs.com", :port => 80)
    assert_equal "uninitialized", connect.status
    connect.wait_until_ready
    assert_equal "running", connect.status 
    connect.disconnect
  end

  def test_error_flag
    connect = Sauce::Connect.new(:host => "saucelabs.com", :port => 80, :username => 'fail')
    start = Time.now
    while Time.now-start < 20 && !connect.error
      sleep 1
    end

    assert connect.error
    connect.disconnect
  end
end
