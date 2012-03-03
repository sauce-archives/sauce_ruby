require 'capybara'
require 'uri'

require 'sauce/connect'

$uri = URI.parse Capybara.app_host || ""
$sauce_tunnel = nil


module Sauce
  module Capybara
    def connect_tunnel(options={})
      unless $sauce_tunnel.nil?
        return $sauce_tunnel
      end
      @sauce_tunnel = Sauce::Connect.new
      $sauce_tunnel.wait_until_ready
    end
    module_function :connect_tunnel

    class Driver < ::Capybara::Selenium::Driver
      def browser
        unless @browser
          puts "[Connecting to Sauce OnDemand...]"
          config = Sauce::Config.new
          @domain = "#{rand(10000)}.test"
          @sauce_tunnel = Sauce::Connect.new(:host => $uri.host || rack_server.host,
                                             :port => $uri.port || rack_server.port,
                                             :domain => $uri.host || @domain,
                                             :quiet => true)
          @sauce_tunnel.wait_until_ready
          @browser = Sauce::Selenium2.new(:browser_url => "http://#{$uri.host || @domain}")
          at_exit do
            @browser.quit
            @sauce_tunnel.disconnect
          end
        end
        @browser
      end

      private

      def url(path)
        if path =~ /^http/
          path
        else
          "http://#{$uri.host || @domain}#{path}"
        end
      end
    end
  end
end

Capybara.register_driver :sauce do |app|
  Sauce::Capybara::Driver.new(app)
end

# Monkeypatch Capybara to not use :selenium driver
require 'capybara/dsl'
module Capybara
  def self.javascript_driver
    @javascript_driver || :sauce
  end
end

# Switch Cucumber stories tagged with @selenium to use sauce
begin
  Before("@selenium") do
    Capybara.current_driver = :sauce
  end
rescue NoMethodError
end
