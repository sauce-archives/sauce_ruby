require "selenium/client"

module Sauce
  class Selenium < Selenium::Client::Driver
    def initialize(opts={})
      @config = Sauce::Config.new(opts)
      super(opts.merge({:host => @config.host, :port => @config.port,
           :browser => @config.to_browser_string, :url => @config.browser_url}))
    end
  end
end
