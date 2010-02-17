require 'helper'

class TestSauce < Test::Unit::TestCase
  context "A Client instance" do
    setup do
      # Create this file and put in your details to run the tests
      account = YAML.load_file "live_account.yml"
      @client = Sauce::Client.new(:username => account["username"],
                                  :access_key => account["access_key"])
      @client.destroy_all_tunnels
    end

    should "initialize with passed variables" do
      client = Sauce::Client.new(:username => "test_user",
                                 :access_key => "abc123")
      assert_equal client.api_url, "https://test_user:abc123@saucelabs.com/rest/test_user/"
    end

    should "create a tunnel with the current user" do
      tunnel = @client.create_tunnel('DomainNames' => ["123.456.789.123"])
      tunnel.refresh!
      assert_not_nil tunnel
      assert_equal "sgrove", tunnel.owner
    end

    should "list current tunnels" do
      @client.create_tunnel('DomainNames' => ["111.111.111.111"])
      @client.create_tunnel('DomainNames' => ["111.111.111.112"])
      @client.create_tunnel('DomainNames' => ["111.111.111.113"])

      tunnels = @client.tunnels
      assert_equal 3, tunnels.select{|t| t.status != "halting"}.count
    end

    should "destroy a tunnel" do
      tunnel = @client.create_tunnel('DomainNames' => ["111.111.111.114"])
      tunnel.destroy
      assert_equal "halting", tunnel.status
    end

    should "destroy all tunnels" do
      @client.create_tunnel('DomainNames' => ["111.111.111.115"])
      @client.create_tunnel('DomainNames' => ["111.111.111.116"])
      @client.create_tunnel('DomainNames' => ["111.111.111.117"])

      @client.destroy_all_tunnels

      @client.tunnels.each do |tunnel|
        assert_equal "halting", tunnel.status
      end
    end

    def teardown
      @client.destroy_all_tunnels
    end
  end
end
