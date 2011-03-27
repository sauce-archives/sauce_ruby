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

  def test_fails_fast_with_no_username
    Sauce.config {|config|}
    username = ENV['SAUCE_USERNAME']
    access_key = ENV['SAUCE_ACCESS_KEY']

    begin
      ENV['SAUCE_USERNAME'] = nil
      assert_raises ArgumentError do
        connect = Sauce::Connect.new(:host => "saucelabs.com", :port => 80)
      end

      ENV['SAUCE_USERNAME'] = username
      ENV['SAUCE_ACCESS_KEY'] = nil
      assert_raises ArgumentError do
        connect = Sauce::Connect.new(:host => "saucelabs.com", :port => 80)
      end
    ensure
      ENV['SAUCE_USERNAME'] = username
      ENV['SAUCE_ACCESS_KEY'] = access_key
    end
  end
end
