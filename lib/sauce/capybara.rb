require 'capybara'

require 'sauce/config'
require 'sauce/selenium'
require 'sauce/version'


$sauce_tunnel = nil

module Sauce
  module Capybara
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

      alias :base_visit :visit
      alias :base_current_url :current_url
      alias :base_within_frame :within_frame
      alias :base_within_window :within_window
      alias :base_find_window :find_window
      alias :base_execute_script :execute_script
      alias :base_evaluate_script :evaluate_script

      @methods_to_retry = [:visit, :current_url,
        :within_frame, :within_window, :find_window, :source,
        :execute_script, :evaluate_script
      ]

      if method_defined? :find
        alias :base_find :find
        @methods_to_retry += [:find]
      else
        alias :base_find_css :find_css
        alias :base_find_xpath :find_xpath
        @methods_to_retry += [:find_css, :find_xpath]
      end

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
          @browser = rspec_browser
          unless @browser
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
      end

      def render(path)
        browser.save_screenshot path
      end
    end

    def self.configure_capybara
      ::Capybara.configure do |config|
        config.server_port = Sauce::Config.get_application_port
        begin
          config.always_include_port = true
        rescue
          # This option is only in Capybara 2+
        end
      end
    end

    def self.configure_capybara_for_rspec
      begin
        require "rspec/core"
        ::RSpec.configure do |config|
          if config.inclusion_filter[:sauce]
            config.before(:suite) do     
              ::Capybara.configure do |config|
                host = Sauce::Config.new[:application_host] || "127.0.0.1"
                port = Sauce::Config.new[:application_port]
                config.app_host = "http://#{host}:#{port}"
                config.run_server = false
              end
            end
          end
        end
      rescue LoadError => e
        # User is not using RSpec
      end
    end
  end
end

Capybara.register_driver :sauce do |app|
  driver = Sauce::Capybara::Driver.new(app)
end

Sauce::Capybara.configure_capybara

# Monkeypatch Capybara to not use :selenium driver
require 'capybara/dsl'
module Capybara
  def self.javascript_driver
    @javascript_driver || :sauce
  end
end

module Sauce
  module RSpec
    module SeleniumExampleGroup
      Sauce::Capybara.configure_capybara_for_rspec
    end
  end
end