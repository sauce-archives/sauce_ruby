require 'jasmine'

module Jasmine
  class SeleniumDriver
    def initialize(browser, http_address)
      @http_address = http_address
      @driver = Sauce::Selenium2.new(:browser => browser, :job_name => job_name)
      puts "Starting job named: #{job_name}"
    end

    def job_name
      "Jasmine Test Run #{Time.now.utc.to_i}"
    end
  end
end
