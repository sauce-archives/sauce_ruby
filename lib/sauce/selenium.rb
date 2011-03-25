require "selenium/client"
require "selenium/webdriver"

module Sauce
  class Selenium < ::Selenium::Client::Driver
    def initialize(opts={})
      @config = Sauce::Config.new(opts)
      super(opts.merge({:host => @config.host, :port => @config.port,
           :browser => @config.to_browser_string, :url => @config.browser_url}))
    end

    def passed!
      self.set_context "sauce:job-result=passed"
    end

    def failed!
      self.set_context "sauce:job-result=failed"
    end
  end

  class Selenium2
    def initialize(opts={})
      @config = Sauce::Config.new(opts)
      http_client = ::Selenium::WebDriver::Remote::Http::Default.new
      http_client.timeout = 300 # Browser launch can take a while
      @driver = ::Selenium::WebDriver.for(:remote, :url => "http://#{@config.username}:#{@config.access_key}@#{@config.host}:#{@config.port}/wd/hub", :desired_capabilities => @config.to_desired_capabilities, :http_client => http_client)
      http_client.timeout = 90 # Once the browser is up, commands should time out reasonably
    end

    def method_missing(meth, *args)
      @driver.send(meth, *args)
    end

    def session_id
      @driver.send(:bridge).session_id
    end

    def stop
      @driver.quit
    end
  end
end
