require 'capybara'
require 'uri'

require 'sauce/config'
require 'sauce/connect'
require 'sauce/selenium'


$uri = URI.parse Capybara.app_host || ""
$sauce_tunnel = nil


module Sauce
  module Capybara
    def connect_tunnel(options={})
      unless $sauce_tunnel.nil?
        return $sauce_tunnel
      end
      uri = URI.parse(::Capybara.app_host || '')
      options.merge!({:host => uri.host,
                      :port => uri.port,
                      :domain => uri.host})

      $sauce_tunnel = Sauce::Connect.new(options)
      $sauce_tunnel.connect
      $sauce_tunnel.wait_until_ready
      $sauce_tunnel
    end
    module_function :connect_tunnel

    class Driver < ::Capybara::Selenium::Driver
      def browser
        unless @browser
          if Sauce.get_config[:start_tunnel]
            Sauce::Capybara.connect_tunnel(:quiet => true)
          end

          @browser = Sauce::Selenium2.new(:browser_url => "http://#{$uri.host}")
          at_exit do
            @browser.quit if @browser
            $sauce_tunnel.disconnect
          end
        end
        @browser
      end

      private

      def url(path)
        if path =~ /^http/
          path
        else
          "http://#{$uri.host}#{path}"
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
