require "sauce/driver_pool"

require "selenium/client"
require "selenium/webdriver"

require 'selenium/webdriver/remote/http/persistent'

module Selenium
  module WebDriver
    class Proxy
      class << self
        alias :existing_json_create :json_create

        def json_create(data)
          dup = data.dup.delete_if {|k,v| v.nil?}
          dup.delete_if {|k,v| k == "autodetect" && v == false}
          existing_json_create(dup)
        end
      end
    end
  end
end


module Sauce
  class Selenium2
    attr_reader :config, :driver

    def initialize(opts={})
      @config = Sauce::Config.new(opts)
      http_client = ::Selenium::WebDriver::Remote::Http::Persistent.new
      http_client.timeout = 300 # Browser launch can take a while
      @driver = ::Selenium::WebDriver.for(:remote,
                      :url => "http://#{@config.username}:#{@config.access_key}@#{@config.host}:#{@config.port}/wd/hub",
                      :desired_capabilities => @config.to_desired_capabilities,
                      :http_client => http_client)
      http_client.timeout = 90 # Once the browser is up, commands should time out reasonably
    end

    def method_missing(meth, *args)
      @driver.send(meth, *args)
    end

    def session_id
      @driver.send(:bridge).session_id
    end

    def current_url
      @driver.current_url
    end

    def stop
      @driver.quit
    end
  end
end
