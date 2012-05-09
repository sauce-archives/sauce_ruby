require 'capybara'
require 'sauce/capybara'

module Sauce::Capybara
  module Drivers
    class RetryableDriver < Sauce::Capybara::Driver
      RETRY_ON = [::Selenium::WebDriver::Error::UnhandledError,
                  ::Selenium::WebDriver::Error::UnknownError]

      def handle_retry(method, *args)
        send("base_#{method}".to_sym, *args)
      end

      alias :base_find :find
      alias :base_visit :visit
      alias :base_current_url :current_url

      [:find, :visit, :current_url].each do |method|
        define_method(method) do |*args|
          handle_retry(method, *args)
        end
      end
    end
  end
end
