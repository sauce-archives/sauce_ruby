require 'rest_client'
require 'json'

module Sauce
  # The module that brokers most communication with Sauce Labs' REST API
  class Client
    class BadAccessError < StandardError; end #nodoc
    class MisconfiguredError < StandardError; end #nodoc

    attr_accessor :username, :access_key, :client, :ip, :api_url
    attr_accessor :tunnels, :jobs

    def initialize(options)
      @username   = options[:username]
      @access_key = options[:access_key]
      @ip         = options[:ip]

      raise MisconfiguredError if @username.nil? or @access_key.nil?
      @api_url = "https://#{@username}:#{@access_key}@saucelabs.com/rest/#{@username}/"
      @client = RestClient::Resource.new @api_url

      @tunnels = Sauce::Tunnel
      @tunnels.client = @client
      @tunnels.account = {:username => @username,
        :access_key => @access_key,
        :ip => @ip}

      @jobs = Sauce::Job
      @jobs.client = @client
      @jobs.account = {:username => @username,
        :access_key => @access_key,
        :ip => @ip}
    end
  end
end
