require 'jasmine'

module Jasmine
  class SeleniumDriver
    attr_reader :http_address, :driver, :browser

    def initialize(browser, http_address)
      @browser = browser
      @http_address = http_address
      name = job_name

      @driver = Sauce::Selenium2.new(:browser => ENV['SAUCE_BROWSER'], :job_name => job_name)
      puts "Starting job named: #{job_name}"
    end

    def job_name
      "Jasmine Test Run #{Time.now.utc.to_i}"
    end
  end
end

module Jasmine
  class Configuration
    def port
      3001
    end
  end
end
