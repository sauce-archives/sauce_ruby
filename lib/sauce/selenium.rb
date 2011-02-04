require "selenium/client"
require "selenium/webdriver"

module Sauce
  class Selenium < Selenium::Client::Driver
    def initialize(opts={})
      @config = Sauce::Config.new(opts)
      super(opts.merge({:host => @config.host, :port => @config.port,
           :browser => @config.to_browser_string, :url => @config.browser_url}))
    end
  end

  class Selenium2
    def initialize(opts={})
      @config = Sauce::Config.new(opts)
      @driver = ::Selenium::WebDriver.for(:remote, :url => "http://#{@config.username}:#{@config.access_key}@#{@config.host}:#{@config.port}/wd/hub", :desired_capabilities => @config.to_desired_capabilities)
    end

    def method_missing(meth, *args)
      @driver.send(meth, *args)
    end

    def stop
      @driver.quit
    end
  end
end
