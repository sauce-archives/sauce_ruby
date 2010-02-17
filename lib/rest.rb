require 'rest_client'
require 'json'

module Sauce
  class Client
    class BadAccessError < StandardError; end #nodoc
    class MisconfiguredError < StandardError; end #nodoc

    attr_accessor :username, :access_key, :client, :api_url

    def initialize(options)
      @username   = options[:username]
      @access_key = options[:access_key]

      raise MisconfiguredError if @username.nil? or @access_key.nil?
      @api_url = "https://#{@username}:#{@access_key}@saucelabs.com/rest/#{@username}/"
      @client = RestClient::Resource.new @api_url
    end

    def create_tunnel(options)
      response = JSON.parse @client[:tunnels].post(options.to_json, :content_type => 'application/json')
      raise Sauce::Client::BadAccessError unless response["error"].nil?
      Sauce::Tunnel.new(@client, response)
    end

    def tunnels(options = {})
      response = JSON.parse @client[:tunnels].get
      return response.collect{|r| Sauce::Tunnel.new(@client, r)}
    end

    def destroy_all_tunnels(options={})
      tunnels.each do |t|
        t.destroy
      end
    end
  end
end
