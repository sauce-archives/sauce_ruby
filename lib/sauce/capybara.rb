require 'capybara'

module Sauce
  module Capybara
    class Driver < ::Capybara::Driver::Selenium
      def browser
        unless @browser
          config = Sauce::Config.new
          @sauce_tunnel = Sauce::Connect.new(:host => "127.0.0.1", :port => rack_server.port)
          @sauce_tunnel.wait_until_ready
          @browser = Sauce::Selenium2.new(:name => "Capybara")
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
          config = Sauce::Config.new
          config.browser_url + path.to_s
        end
      end
    end
  end
end

Capybara.register_driver :sauce do |app|
  Sauce::Capybara::Driver.new(app)
end
