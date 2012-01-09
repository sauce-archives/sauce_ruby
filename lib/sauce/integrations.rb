begin
  require 'spec'
  module Sauce
    module RSpec
      class SeleniumExampleGroup < Spec::Example::ExampleGroup
        attr_reader :selenium
        @@need_tunnel = false

        def self.inherited(subclass)
          # only setup tunnel if somebody needs it
          @@need_tunnel = true
          super(subclass)
        end

        before :suite do
          config = Sauce::Config.new
          if @@need_tunnel
            if config.application_host && !config.local?
              @@tunnel = Sauce::Connect.new(:host => config.application_host, :port => config.application_port || 80)
              @@tunnel.wait_until_ready
            end
            if Sauce::Utilities::RailsServer.is_rails_app?
              @@server = Sauce::Utilities::RailsServer.new
              @@server.start
            end
          end
        end

        after :suite do
          @@tunnel.disconnect if defined? @@tunnel
          @@server.stop if defined? @@server
        end

        def execute(*args)
          config = Sauce::Config.new
          description = [self.class.description, self.description].join(" ")
          config.browsers.each do |os, browser, version|
            if config.single_session?
              if config.local?
                @selenium = Sauce.cached_session(:host => "127.0.0.1", :port => 4444, :browser => "*" +
                                                browser, :url => "http://127.0.0.1:#{config.local_application_port}/")
              else
                @selenium = Sauce.cached_session({:os => os, :browser => browser, :browser_version => version,
                               :job_name => self.class.description})
              end
              super(*args)
            else
              if config.local?
                @selenium = ::Selenium::Client::Driver.new(:host => "127.0.0.1",
                                                           :port => 4444,
                                                           :browser => "*" + browser,
                                                           :url => "http://127.0.0.1:#{config.local_application_port}/")
              else
                @selenium = Sauce::Selenium.new({:os => os, :browser => browser, :browser_version => version,
                                                :job_name => "#{description}"})
              end
              @selenium.start_new_browser_session(:captureNetworkTraffic => config.capture_traffic?)
              super(*args)
              @selenium.stop
            end
          end
        end

        alias_method :page, :selenium
        alias_method :s, :selenium

        Spec::Example::ExampleGroupFactory.register(:selenium, self)
      end
    end
  end
rescue LoadError
  # User doesn't have RSpec 1.x installed
end

begin
  require 'rspec'
  module Sauce
    module RSpec
      module SeleniumExampleGroup
        attr_reader :selenium
        alias_method :page, :selenium
        alias_method :s, :selenium

        def self.included(othermod)
          othermod.around do |the_test|
            config = Sauce::Config.new
            description = the_test.metadata[:full_description]
            config.browsers.each do |os, browser, version|
              if config.local?
                @selenium = ::Selenium::Client::Driver.new(:host => "127.0.0.1",
                                                           :port => 4444,
                                                           :browser => "*" + browser,
                                                           :url => "http://127.0.0.1:#{config.local_application_port}/")
              else
                @selenium = Sauce::Selenium.new({:os => os, :browser => browser, :browser_version => version,
                                                :job_name => "#{description}"})
              end
              @selenium.start_new_browser_session(:captureNetworkTraffic => config.capture_traffic?)
              begin
                the_test.run
              ensure
                @selenium.stop
              end
            end
          end
        end

        ::RSpec.configuration.include(self, :example_group => {
              :file_path => Regexp.compile('spec[\\\/]selenium')
            })
        ::RSpec.configuration.before :suite do
          need_tunnel = false
          config = Sauce::Config.new
          files_to_run = ::Rspec.configuration.respond_to?(:files_to_run) ? ::Rspec.configuration.files_to_run :
            ::RSpec.configuration.settings[:files_to_run]
          if config.application_host && !config.local?
            need_tunnel = files_to_run.any? {|file| file =~ /spec\/selenium\//}
          end
          if need_tunnel
            @@tunnel = Sauce::Connect.new(:host => config.application_host, :port => config.application_port || 80)
            @@tunnel.wait_until_ready
          end

          if files_to_run.any? {|file| file =~ /spec\/selenium\//} &&
            Sauce::Utilities::RailsServer.is_rails_app?
            @@server = Sauce::Utilities::RailsServer.new
            @@server.start
          end
        end
        ::RSpec.configuration.after :suite do
          @@tunnel.disconnect if defined? @@tunnel
          @@server.stop if defined? @@server
        end
      end
    end
  end
rescue LoadError, TypeError
  # User doesn't have RSpec 2.x installed
end

module Sauce
  module SeleniumForTestUnit
    attr_reader :browser

    alias_method :page, :browser
    alias_method :s, :browser
    alias_method :selenium, :browser

    def run(*args, &blk)
      if self.respond_to? :name
        my_name = self.name
      else
        my_name = self.__name__
      end
      unless my_name =~ /^default_test/
        config = Sauce::Config.new
        if config.application_host && !config.local?
          unless ENV['TEST_ENV_NUMBER'].to_i > 1
            Sauce::Connect.ensure_connected(:host => config.application_host, :port => config.application_port || 80)
          end
        end

        unless defined?(@@server)
          unless ENV['TEST_ENV_NUMBER'].to_i > 1
            if Sauce::Utilities::RailsServer.is_rails_app?
              @@server = Sauce::Utilities::RailsServer.new
              @@server.start
              at_exit do
                @@server.stop
              end
            end
          end
        end

        config.browsers.each do |os, browser, version|
          if config.single_session?
            if config.local?
              @browser = Sauce.cached_session(:host => "127.0.0.1", :port => 4444, :browser => "*" +
                                              browser, :url => "http://127.0.0.1:#{config.local_application_port}/")
            else
              options = self.class.sauce_config
              options.merge!({:os => os, :browser => browser, :browser_version => version,
                             :job_name => "#{Rails.root.split[1].to_s} test suite"})
              @browser = Sauce.cached_session(options)
            end
            super(*args, &blk)
          else
            if config.local?
              @browser = ::Selenium::Client::Driver.new(:host => "127.0.0.1",
                                                        :port => 4444,
                                                        :browser => "*" + browser,
                                                        :url => "http://127.0.0.1:#{config.local_application_port}/")
            else
              options = self.class.sauce_config
              options.merge!({:os => os, :browser => browser, :browser_version => version,
                                             :job_name => "#{my_name}"})
              @browser = Sauce::Selenium.new(options)
            end
            if self.class.selenium_flags
              @browser.start_new_browser_session(self.class.selenium_flags.merge(:captureNetworkTraffic => config.capture_traffic?))
            else
              @browser.start_new_browser_session(:captureNetworkTraffic => config.capture_traffic?)
            end
            super(*args, &blk)
            @browser.stop
          end
        end
      end
    end
  end
end

module Sauce
  module SeleniumForTestUnitClassMethods
    def selenium_flags=(options)
      @selenium_flags = options
    end

    def selenium_flags
      return @selenium_flags
    end

    def sauce_config=(config)
      @sauce_config = config
    end

    def sauce_config
      @sauce_config || {}
    end
  end
end

if defined?(ActiveSupport::TestCase)
  module Sauce
    class RailsTestCase < ::ActiveSupport::TestCase
      include SeleniumForTestUnit
      extend SeleniumForTestUnitClassMethods

      # Placeholder so test/unit ignores test cases without any tests.
      def default_test
      end
    end
  end
end

begin
  require 'test/unit/testcase'
  module Sauce
    class TestCase < Test::Unit::TestCase
      include SeleniumForTestUnit
      extend SeleniumForTestUnitClassMethods

      # Placeholder so test/unit ignores test cases without any tests.
      def default_test
      end
    end
  end
rescue LoadError
  # User doesn't have Test::Unit installed
end
