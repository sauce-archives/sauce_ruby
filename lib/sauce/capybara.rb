require 'capybara'

require 'sauce/config'
require 'sauce/connect'
require 'sauce/selenium'


$sauce_tunnel = nil

module Sauce
  module Capybara
    def connect_tunnel(options={})
      unless $sauce_tunnel.nil?
        return $sauce_tunnel
      end
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

          @browser = Sauce::Selenium2.new
          at_exit do
            @browser.quit if @browser
            $sauce_tunnel.disconnect if $sauce_tunnel
          end
        end
        @browser
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
