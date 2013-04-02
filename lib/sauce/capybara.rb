require 'capybara'

require 'sauce/config'
require 'sauce/selenium'


$sauce_tunnel = nil

module Sauce
  module Capybara
    def connect_tunnel(options={})
      begin
        require 'sauce/connect'
      rescue LoadError
        puts 'Please install the `sauce-connect` gem if you intend on using Sauce Connect with your tests!'
        raise
      end

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
      RETRY_ON = [::Selenium::WebDriver::Error::UnhandledError,
                  ::Selenium::WebDriver::Error::UnknownError]
      MAX_RETRIES = 3

      def handle_retry(method, *args, &block)
        retries = 0

        # Disable retries only when we really really want to, this will remain
        # an undocomented hack for the time being
        if ENV['SAUCE_DISABLE_RETRY']
          retries = MAX_RETRIES
        end

        begin
          send("base_#{method}".to_sym, *args, &block)
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
      alias :base_reset! :reset!
      alias :base_within_frame :within_frame
      alias :base_within_window :within_window
      alias :base_find_window :find_window
      alias :base_execute_script :execute_script
      alias :base_evaluate_script :evaluate_script

      @methods_to_retry = [ :find, :visit, :current_url, :reset!,
        :within_frame, :within_window, :find_window, :source,
        :execute_script, :evaluate_script
      ]

      if Gem::Version.new(::Capybara::VERSION) < Gem::Version.new(2)
        alias :base_body :body
        alias :base_source :source

        @methods_to_retry + [:body, :source]
      else
        alias :base_html :html
        @methods_to_retry + [:html]
      end

      @methods_to_retry.each do |method|
        define_method(method) do |*args, &block|
          handle_retry(method, *args, &block)
        end
      end

      def browser
        unless existing_browser?
          unless @browser = rspec_browser
            if Sauce.get_config[:start_tunnel]
              Sauce::Capybara.connect_tunnel(:quiet => true)
            end

            @browser = Sauce::Selenium2.new
            at_exit do
              finish!
            end
          end
        end
        @browser
      end

      def rspec_browser
        if browser = Sauce.driver_pool[Thread.current.object_id]
          @using_rspec_browser = true
        else
          @using_rspec_browser = false
        end
        browser
      end

      def existing_browser?
        if @using_rspec_browser
          @browser == Sauce.driver_pool[Thread.current.object_id]
        else
          @browser
        end
      end

      def finish!
        @browser.quit if existing_browser?
        @browser = nil
        $sauce_tunnel.disconnect if $sauce_tunnel
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
