require 'capybara'
require 'sauce/capybara'

module Sauce::Capybara
  module Drivers
    class RetryableDriver < Sauce::Capybara::Driver
      RETRY_ON = [::Selenium::WebDriver::Error::UnhandledError,
                  ::Selenium::WebDriver::Error::UnknownError]
      MAX_RETRIES = 3

      def handle_retry(method, *args)
        retries = 0
        begin
          send("base_#{method}".to_sym, *args)
        rescue *RETRY_ON => e
          if retries < MAX_RETRIES
            puts "Received an exception (#{e}), retrying"
            retries = retries + 1
            retry
          else
            raise
          end
        end
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
