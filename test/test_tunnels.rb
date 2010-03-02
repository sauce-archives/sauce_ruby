require 'helper'

class TestSauce < Test::Unit::TestCase
  context "A V1 tunnel instance" do
    setup do
      # Create this file and put in your details to run the tests
      account = YAML.load_file "live_account.yml"
      @username = account["username"]
      @access_key = account["access_key"]
      @ip = account["ip"]
      @client = Sauce::Client.new(:username => @username,
                                  :access_key => @access_key)
      @client.tunnels.destroy_all
    end

    should "initialize with passed variables" do
      client = Sauce::Client.new(:username => "test_user",
                                 :access_key => "abc123")
      assert_equal "https://test_user:abc123@saucelabs.com/api/v1/test_user/", client.api_url
    end

    should "create a tunnel with the current user" do
      tunnel = @client.tunnels.create('DomainNames' => ["192.168.0.110"])
      tunnel.refresh!
      assert_not_nil tunnel
      assert_equal @username, tunnel.owner
    end

    should "list current tunnels" do
      @client.tunnels.create('DomainNames' => ["192.168.0.111"])
      @client.tunnels.create('DomainNames' => ["192.168.0.112"])
      @client.tunnels.create('DomainNames' => ["192.168.0.113"])

      tunnels = @client.tunnels.all
      assert_equal 3, tunnels.select{|t| t.status != "halting"}.count
    end

    should "destroy a tunnel" do
      tunnel = @client.tunnels.create('DomainNames' => ["192.168.0.114"])
      tunnel.destroy
      assert_equal "halting", tunnel.status
    end

    should "destroy all tunnels" do
      tunnel = @client.tunnels.create('DomainNames' => ["192.168.0.115"])
      tunnel = @client.tunnels.create('DomainNames' => ["192.168.0.116"])
      tunnel = @client.tunnels.create('DomainNames' => ["192.168.0.117"])

      @client.tunnels.destroy_all

      @client.tunnels.all.each do |tunnel|
        assert_equal "halting", tunnel.status
      end
    end

    should "say hello on port 1025 if healthy" do
      tunnel = @client.tunnels.create('DomainNames' => [@ip])

      max_retries = 30
      retries = 0
      until tunnel.status == "running" or retries >= max_retries
        sleep 5
        retries += 1
        tunnel.refresh!
      end

      assert_equal true, tunnel.says_hello?

      tunnel.destroy # cleanup
    end

    should "not attempt to telnet if status is not running" do
      tunnel = @client.tunnels.create('DomainNames' => [@ip])

      tunnel.status = "booting"
      assert_equal false, tunnel.says_hello?
    end

    def teardown
      @client.tunnels.destroy_all
    end
  end
end
