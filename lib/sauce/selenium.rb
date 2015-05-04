require "forwardable"
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
          # Some platforms derp up JSON encoding proxy details,
          # notably Appium.
          if (data.class == String)
            data = JSON.parse data if data.start_with? "{\"proxy"
          end

          dup = data.dup.delete_if {|k,v| v.nil?}
          dup.delete_if {|k,v| k == "autodetect" && v == false}
          existing_json_create(dup)
        end
      end
    end
  end
end

module Sauce
  class << self
    attr_accessor :webdriver_method
  end
  @webdriver_method = lambda { |*args| ::Selenium::WebDriver.for *args }
end

module Sauce
  class Selenium2
    extend Forwardable

    attr_reader :config, :driver, :watir

    def_delegator :@driver, :execute_script

    def self.used_at_least_once?
      @used_at_least_once || false
    end

    def self.used_at_least_once
      @used_at_least_once = true
    end

    def initialize(opts={})
      @config = Sauce::Config.new(opts)
      http_client = ::Selenium::WebDriver::Remote::Http::Persistent.new
      http_client.timeout = 300 # Browser launch can take a while

      @driver = Sauce.webdriver_method.call(:remote,
                      :url => "http://#{@config.username}:#{@config.access_key}@#{@config.host}:#{@config.port}/wd/hub",
                      :desired_capabilities => @config.to_desired_capabilities,
                      :http_client => http_client)
      http_client.timeout = 90 # Once the browser is up, commands should time out reasonably

      @watir = defined?(Watir::Browser) && @driver.is_a?(Watir::Browser)

      raw_driver.file_detector = lambda do |args|
        file_path = args.first.to_s
        File.exist?(file_path) ? file_path : false
      end

      Sauce::Selenium2.used_at_least_once
    end

    def raw_driver
      watir ? @driver.driver : @driver
    end

    def method_missing(meth, *args)
      @driver.send(meth, *args)
    end

    def session_id
      raw_driver.send(:bridge).session_id
    end

    def current_url
      raw_driver.current_url
    end

    def stop
      @driver.quit
    end
  end
end
