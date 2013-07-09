require 'sauce/utilities'
require "sauce_whisk"

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
            if config[:application_host]
              Sauce::Utilities::Connect.start(:host => config[:application_host], :port => config[:application_port] || 80)
            end
            if config[:start_local_application] &&
              Sauce::Utilities::RailsServer.is_rails_app?
              @@server = Sauce::Utilities::RailsServer.new
              @@server.start
            end
          end
        end

        after :suite do
          Sauce::Utilities::Connect.close
          @@server.stop if defined? @@server
        end

        def execute(*args)
          config = Sauce::Config.new
          description = [self.class.description, self.description].join(" ")
          config[:browsers].each do |os, browser, version|
            @selenium = Sauce::Selenium2.new({:os => os, :browser => browser,
                                              :browser_version => version,
                                              :job_name => description})
            super(*args)

            @selenium.stop
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
rescue => e
  STDERR.puts "Exception occured: #{e.to_s}"
end

begin
  require 'rspec/core'
  module Sauce
    module RSpec
      module SeleniumExampleGroup
        attr_reader :selenium
        alias_method :s, :selenium

        def page
          warn Sauce::Utilities.page_deprecation_message
          @selenium
        end

        def self.included(othermod)
          othermod.around do |the_test|
            config = Sauce::Config.new
            description = the_test.metadata[:full_description]
            file = the_test.metadata[:file_path]
            config.browsers_for_file(file).each do |os, browser, version|
              @selenium = Sauce::Selenium2.new({:os => os,
                                                :browser => browser,
                                                :browser_version => version,
                                                :job_name => description})
              Sauce.driver_pool[Thread.current.object_id] = @selenium

              begin
                the_test.run
                SauceWhisk::Jobs.change_status @selenium.session_id, example.exception.nil?
              ensure
                @selenium.stop
                Sauce.driver_pool.delete Thread.current.object_id
              end
            end
          end
        end

        ::RSpec.configuration.include(self, :example_group => {
              :file_path => Regexp.compile('spec[\\\/]selenium')
            })
        ::RSpec.configuration.include(self, :sauce => true)

        ::RSpec.configuration.before(:suite, :sauce => true) do

          config = Sauce::Config.new
          if config[:application_host]
            Sauce::Utilities::Connect.start(:host => config[:application_host], :port => config[:application_port] || 80, :quiet => true)
          end

          if config[:start_local_application] &&
            Sauce::Utilities::RailsServer.is_rails_app?
            # Start the app before the tests if this is a parallel run
            if ENV["TEST_ENV_NUMBER"].nil?
              @@server = Sauce::Utilities::RailsServer.new
              @@server.start
            end
          end
        end

        ::RSpec.configuration.before :suite do
          need_tunnel = false
          config = Sauce::Config.new
          files_to_run = ::RSpec.configuration.respond_to?(:files_to_run) ? ::RSpec.configuration.files_to_run :
            ::RSpec.configuration.settings[:files_to_run]
          if config[:application_host]
            need_tunnel = files_to_run.any? {|file| file =~ /spec\/selenium\//}
          end

          if need_tunnel || config[:start_tunnel]
            Sauce::Utilities::Connect.start(:host => config[:application_host], :port => config[:application_port] || 80, :quiet => true)
          end

          if config[:start_local_application] &&
            files_to_run.any? {|file| file =~ /spec\/selenium\//} &&
            Sauce::Utilities::RailsServer.is_rails_app?
            ## Only open the tunnel once.
            ## TODO:  Why is this here?  It's above, also
            @@server = Sauce::Utilities::RailsServer.new
            @@server.start
          end
        end
        ::RSpec.configuration.after :suite do
          Sauce::Utilities::Connect.close
          @@server.stop if defined? @@server
        end
      end
    end
  end
rescue LoadError, TypeError
  # User doesn't have RSpec 2.x installed
rescue => e
  STDERR.puts "Exception caught: #{e.to_s}"
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

        config[:browsers].each do |os, browser, version|
          options = self.class.sauce_config
          options.merge!({:os => os, :browser => browser,
                          :browser_version => version,
                          :job_name => my_name.to_s})
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
  if Object.const_defined? "Test"
    if Test.const_defined? "Unit"
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
