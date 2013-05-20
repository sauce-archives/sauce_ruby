require 'jasmine'

module Sauce
  module Jasmine
    class Driver < ::Jasmine::SeleniumDriver
      attr_reader :http_address, :driver, :browser

      def initialize(browser, http_address)
        @browser = browser
        @http_address = http_address
        name = job_name
        @driver = Sauce::Selenium2.new(:browser => browser, :job_name => name)
        puts "Starting job named: #{name}"
      end

      def job_name
        "Jasmine Test Run #{Time.now.utc.to_i}"
      end
    end
  end
end

module Jasmine
  class Config
    def jasmine_port
      '3001'
    end

    def start
      @client = ::Sauce::Jasmine::Driver.new(browser, "#{jasmine_host}:#{jasmine_port}/")
      @client.connect
    end
  end
end


