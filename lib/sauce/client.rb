require 'rest_client'
require 'json'

module Sauce
  # The module that brokers most communication with Sauce Labs' REST API
  class Client
    class BadAccessError < StandardError; end #:nodoc
    class MisconfiguredError < StandardError; end #:nodoc

    attr_accessor :client
    attr_accessor :protocol, :host, :port, :api_path, :api_version, :ip, :api_url
    attr_accessor :tunnels, :jobs

    def initialize(options={})
      config = Sauce::Config.new

      @protocol   = options[:protocol] || "http"
      @host       = options[:host] || "saucelabs.com"
      @port       = options[:port] || 80
      @api_path   = options[:api_path] || "rest"
      @api_version= options[:api_version] || 1

      raise MisconfiguredError if config.username.nil? or config.access_key.nil?
      @api_url = "#{@protocol}://#{config.username}:#{config.access_key}@#{@host}:#{@port}/#{@api_path}/v#{@api_version}/#{@username}/"
      @client = RestClient::Resource.new @api_url

      @tunnels = Sauce::Tunnel
      @tunnels.client = @client
      @tunnels.account = {
        :username => config.username,
        :access_key => config.access_key,
        :ip => @ip}

      @jobs = Sauce::Job
      @jobs.client = @client
      @jobs.account = {
        :username => config.username,
        :access_key => config.access_key,
        :ip => @ip
      }
    end

    def [](url)
      @client[url]
    end
  end
end
