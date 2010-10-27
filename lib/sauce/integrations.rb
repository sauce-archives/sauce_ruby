begin
  require 'spec'
  module Sauce
    module RSpec
      class SeleniumExampleGroup < Spec::Example::ExampleGroup
        attr_reader :selenium

        before :suite do
          config = Sauce::Config.new
          if config.application_host
            @@tunnel = Sauce::Connect.new(:host => config.application_host, :port => config.application_port || 80)
            @@tunnel.wait_until_ready
          end
        end

        after :suite do
          if defined? @@tunnel
            @@tunnel.disconnect
          end
        end

        before(:each) do
          @selenium.start
        end

        after(:each) do
          @selenium.stop
        end

        def execute(*args)
          config = Sauce::Config.new
          description = [self.class.description, self.description].join(" ")
          config.browsers.each do |os, browser, version|
            @selenium = Sauce::Selenium.new({:os => os, :browser => browser, :browser_version => version,
              :job_name => "#{description}"})
            super(*args)
          end
        end

        alias_method :page, :selenium
        alias_method :s, :selenium

        Spec::Example::ExampleGroupFactory.register(:selenium, self)
      end
    end
  end
rescue LoadError
  # User doesn't have RSpec installed
end

begin
  require 'test/unit'
  module Sauce
    class TestCase < Test::Unit::TestCase
      attr_reader :selenium

      alias_method :page, :selenium
      alias_method :s, :selenium

      def run(*args, &blk)
        unless name =~ /^default_test/
          config = Sauce::Config.new
          config.browsers.each do |os, browser, version|
            @selenium = Sauce::Selenium.new({:os => os, :browser => browser, :browser_version => version,
              :job_name => "#{name}"})
            @selenium.start
            super(*args, &blk)
            @selenium.stop
          end
        end
      end

      # Placeholder so test/unit ignores test cases without any tests.
      def default_test
      end

      def self.ensure_tunnel_running
        unless defined?(@tunnel)
        end
      end
    end
  end
  require 'test/unit/ui/console/testrunner'
  class Test::Unit::UI::Console::TestRunner
    def attach_to_mediator_with_sauce_tunnel
      @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::STARTED, &method(:start_tunnel))
      @mediator.add_listener(Test::Unit::UI::TestRunnerMediator::FINISHED, &method(:stop_tunnel))
      attach_to_mediator_without_sauce_tunnel
    end

    alias_method :attach_to_mediator_without_sauce_tunnel, :attach_to_mediator
    alias_method :attach_to_mediator, :attach_to_mediator_with_sauce_tunnel

    private

    def start_tunnel(msg)
      config = Sauce::Config.new
      if config.application_host
        @sauce_tunnel = Sauce::Connect.new(:host => config.application_host, :port => config.application_port || 80)
        @sauce_tunnel.wait_until_ready
      end
    end

    def stop_tunnel(msg)
      if defined? @sauce_tunnel
        @sauce_tunnel.disconnect
      end
    end
  end
rescue LoadError
  # User doesn't have Test::Unit installed
end
