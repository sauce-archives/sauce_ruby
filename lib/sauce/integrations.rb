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
          if @@need_tunnel && config.application_host && !config.local?
            @@tunnel = Sauce::Connect.new(:host => config.application_host, :port => config.application_port || 80)
            @@tunnel.wait_until_ready
          end
        end

        after :suite do
          if defined? @@tunnel
            @@tunnel.disconnect
          end
        end

        def execute(*args)
          config = Sauce::Config.new
          description = [self.class.description, self.description].join(" ")
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
            @selenium.start
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
              @selenium.start
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
          if config.application_host && !config.local?
            need_tunnel = ::RSpec.configuration.settings[:files_to_run].any? {|file| file =~ /spec\/selenium\//}
          end
          if need_tunnel
            @@tunnel = Sauce::Connect.new(:host => config.application_host, :port => config.application_port || 80)
            @@tunnel.wait_until_ready
          end
        end
        ::RSpec.configuration.after :suite do
          if defined? @@tunnel
            @@tunnel.disconnect
          end
        end
      end
    end
  end
rescue LoadError, TypeError
  # User doesn't have RSpec 2.x installed
end

begin
  require 'test/unit/testcase'
  module Sauce
    class TestCase < Test::Unit::TestCase
      attr_reader :selenium

      alias_method :page, :selenium
      alias_method :s, :selenium

      def run(*args, &blk)
        if self.respond_to? :name
          my_name = self.name
        else
          my_name = self.__name__
        end
        unless my_name =~ /^default_test/
          config = Sauce::Config.new
          config.browsers.each do |os, browser, version|
            if config.local?
              @selenium = ::Selenium::Client::Driver.new(:host => "127.0.0.1",
                                                         :port => 4444,
                                                         :browser => "*" + browser,
                                                         :url => "http://127.0.0.1:#{config.local_application_port}/")
            else
              @selenium = Sauce::Selenium.new({:os => os, :browser => browser, :browser_version => version,
                :job_name => "#{my_name}"})
            end
            @selenium.start
            super(*args, &blk)
            @selenium.stop
          end
        end
      end

      # Placeholder so test/unit ignores test cases without any tests.
      def default_test
      end
    end
  end
rescue LoadError
  # User doesn't have Test::Unit installed
end

begin
  require 'test/unit/autorunner'
  if defined?(Test::Unit::AutoRunner)
    class Test::Unit::AutoRunner
      run_without_tunnel = self.instance_method(:run)

      define_method(:run) do |*args|
        @suite = @collector[self]
        need_tunnel = suite.tests.any? do |test_suite|
          test_suite.tests.any? do |test_case|
            test_case.class.superclass.to_s =~ /^Sauce::/
          end
        end
        if need_tunnel
          config = Sauce::Config.new
          if config.application_host && !config.local?
            @sauce_tunnel = Sauce::Connect.new(:host => config.application_host, :port => config.application_port || 80)
            @sauce_tunnel.wait_until_ready
          end
        end
        result = run_without_tunnel.bind(self).call(*args)
        if defined? @sauce_tunnel
          @sauce_tunnel.disconnect
        end
        return result
      end
    end
  end
rescue LoadError, NameError
  # Ruby 1.8's Test::Unit not found
end

begin
  require 'minitest/unit'
  module MiniTest
    class Unit
      run_without_tunnel = self.instance_method(:run_test_suites)

      define_method(:run_test_suites) do |*args|
        need_tunnel = TestCase.test_suites.any? do |suite|
          suite.superclass.to_s =~ /^Sauce::/
        end
        if need_tunnel
          config = Sauce::Config.new
          if config.application_host && !config.local?
            @sauce_tunnel = Sauce::Connect.new(:host => config.application_host, :port => config.application_port || 80)
            @sauce_tunnel.wait_until_ready
          end
        end
        result = run_without_tunnel.bind(self).call(*args)
        if defined? @sauce_tunnel
          @sauce_tunnel.disconnect
        end
        return result
      end
    end
  end
rescue LoadError
  # User is not on Ruby 1.9
end

if defined?(ActiveSupport::TestCase)
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
          config.browsers.each do |os, browser, version|
            if config.single_session?
              if config.local?
                @browser = Sauce.cached_session(:host => "127.0.0.1", :port => 4444, :browser => "*" +
                                                browser, :url => "http://127.0.0.1:#{config.local_application_port}/")
              else
                @browser = Sauce.cached_session({:os => os, :browser => browser, :browser_version => version,
                  :job_name => "#{Rails.root.split[1].to_s} test suite"})
              end
              super(*args, &blk)
            else
              if config.local?
                @browser = ::Selenium::Client::Driver.new(:host => "127.0.0.1",
                                                           :port => 4444,
                                                           :browser => "*" + browser,
                                                           :url => "http://127.0.0.1:#{config.local_application_port}/")
              else
                @browser = Sauce::Selenium.new({:os => os, :browser => browser, :browser_version => version,
                  :job_name => "#{my_name}"})
              end
              @browser.start
              super(*args, &blk)
              @browser.stop
            end
          end
        end
      end
    end

    class RailsTestCase < ::ActiveSupport::TestCase
      include SeleniumForTestUnit

      # Placeholder so test/unit ignores test cases without any tests.
      def default_test
      end
    end
  end
end
