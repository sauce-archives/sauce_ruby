require 'sauce/utilities'
require "sauce_whisk"

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
        if config[:application_host]
          unless ENV['TEST_ENV_NUMBER'].to_i > 1
            Sauce::Connect.ensure_connected(:host => config[:application_host], :port => config[:application_port] || 80)
          end
        end

        unless defined?(@@server)
          unless ENV['TEST_ENV_NUMBER'].to_i > 1
            if config[:start_local_application] &&
                Sauce::Utilities::RailsServer.is_rails_app?
              @@server = Sauce::Utilities::RailsServer.new
              @@server.start
              at_exit do
                @@server.stop
              end
            end
          end
        end

        config[:browsers].each do |os, browser, version, caps|
          options = self.class.sauce_config
          options.merge!({:os              => os,
                          :browser         => browser,
                          :browser_version => version,
                          :job_name        => my_name.to_s,
                          :caps            => caps})
          @browser = Sauce::Selenium2.new(options)
          Sauce.driver_pool[Thread.current.object_id] = @browser

          super(*args, &blk)

          SauceWhisk::Jobs.change_status @browser.session_id, passed?
          @browser.stop
          Sauce.driver_pool.delete Thread.current.object_id
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
  if Object.const_defined? :Test
    if Test.const_defined? :Unit
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
    end
  end
rescue LoadError
  # User doesn't have Test::Unit installed
rescue => e
  STDERR.puts "Exception caught: #{e.to_s}"
end
