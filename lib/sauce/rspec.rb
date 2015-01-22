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
              Sauce::Utilities::Connect.start(:host => config[:application_host], :port => config[:application_port])
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

            begin
              success = super(*args)
              SauceWhisk::Jobs.change_status @selenium.session_id, success
            ensure
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
rescue => e
  STDERR.puts "Exception occured: #{e.to_s}"
  exit 1
end

begin
  require 'rspec/core'
  module Sauce
    module RSpec
      @@server = nil

      def self.server
        return @@server
      end

      def self.server=(s)
        @@server = s
      end

      def self.setup_environment
        ::RSpec.configuration.before(:all, :sauce => true) do
          Sauce::RSpec.start_tools_for_sauce_tag
        end

        ::RSpec.configuration.before :all do
          Sauce::RSpec.start_tools_for_selenium_directory
          Sauce::RSpec.register_default_hook
          Sauce::RSpec.register_jenkins_hook if ENV['JENKINS_SERVER_COOKIE']
        end
        
        ::RSpec.configuration.after :suite do
          Sauce::RSpec.stop_tools
        end
      end

      def self.start_tools_for_sauce_tag
        config = Sauce::Config.new
        if config[:start_tunnel]
          Sauce::Utilities::Connect.start_from_config(config)
        end

        unless self.server
          self.server= Sauce::Utilities::RailsServer.start_if_required(config)
        end
      end

      def self.start_tools_for_selenium_directory
        config = Sauce::Config.new
        # TODO: Check which rspec version this changed in -- If < 2, change.
        files_to_run = ::RSpec.configuration.respond_to?(:files_to_run) ? ::RSpec.configuration.files_to_run :
          ::RSpec.configuration.settings[:files_to_run]

        running_selenium_specs = files_to_run.any? {|file| file =~ /spec\/selenium\//}
        need_tunnel = running_selenium_specs && config[:application_host]

        if need_tunnel && config[:start_tunnel]
          Sauce::Utilities::Connect.start_from_config(config)
        end

        if running_selenium_specs
          unless self.server
            self.server= Sauce::Utilities::RailsServer.start_if_required(config)
          end
        end
      end

      def self.register_default_hook
        Sauce.config do |c|
          c.after_job :rspec do |id, platform, name, success|
            SauceWhisk::Jobs.change_status id, success
          end
        end
      end

      def self.register_jenkins_hook
        Sauce.config do |c|
          c.after_job :jenkins do |id, platform, name, success|
            puts "SauceOnDemandSessionID=#{id} job-name=#{name}"
          end
        end
      end
      
      def self.stop_tools
        Sauce::Utilities::Connect.close
        server.stop if self.server
        Sauce::Utilities.warn_if_suspect_misconfiguration
      end

      module SeleniumExampleGroup
        include Sauce::TestBase
        attr_reader :selenium
        alias_method :s, :selenium

        def self.rspec_current_example
          lambda { |context| ::RSpec.current_example }
        end

        def self.context_example
          lambda { |context| context.example }
        end

        def self.find_example_method
          ::RSpec.respond_to?(:current_example) ? rspec_current_example : context_example 
        end

        def self.current_example
          @@current_example_fetcher ||= find_example_method
        end

        # TODO V4 -- Remove this entirely
        def page
          if self.class.included_modules.any? {|m| m.name == 'Capybara::DSL'}
            ::Capybara.current_session
          else
            warn Sauce::Utilities.page_deprecation_message
            @selenium
          end
        end

        def self.included(othermod)
          othermod.around do |the_test|
            config = Sauce::Config.new
            description = the_test.metadata[:full_description]
            file = the_test.metadata[:file_path]
            exceptions = {}
            test_each config.caps_for_location(file), description do |selenium, caps|

              example = SeleniumExampleGroup.current_example.call(self)
              example.instance_variable_set(:@exception, nil)
              
              @selenium = selenium
              Sauce.driver_pool[Thread.current.object_id] = @selenium
              example.metadata[:sauce_public_link] = SauceWhisk.public_link(@selenium.session_id)

              begin
                the_test.run
                success = example.exception.nil?
              ensure
                @selenium.stop
                begin
                  os = caps[:os]
                  browser = caps[:browser]
                  version = caps[:version]
                  unless success
                    exceptions["#{os} - #{browser} #{version}"] = example.exception
                  end
                  platform = {:os => os, :browser => browser, :version => version}
                  config.run_post_job_hooks(@selenium.session_id, platform, description, success)
                rescue Exception => e
                  STDERR.puts "Error running post job hooks"
                  STDERR.puts e
                end
                Sauce.driver_pool.delete Thread.current.object_id
              end
              if (exceptions.length > 0)
                example.instance_variable_set(:@exception, exceptions.first[1])
              end
            end
          end
        end

        def self.inclusion_params
          params = [self]
          gem_version = Gem::Version.new ::RSpec::Core::Version::STRING
          file_path_hash = {:file_path => Regexp.compile('spec[\\\/]selenium')}
          if (gem_version >= Gem::Version.new('2.99.0'))
            params = params + [file_path_hash]
          else
            params = params + [{:example_group => file_path_hash}]
          end
          params
        end

        ::RSpec.configuration.include(*self.inclusion_params)
        ::RSpec.configuration.include(self, :sauce => true)

        Sauce::RSpec.setup_environment
      end
    end
  end
rescue LoadError, TypeError
  # User doesn't have RSpec 2.x installed
rescue => e
  STDERR.puts "Exception caught: #{e.to_s}"
  exit 1
end

begin
  require 'rspec/core/formatters/base_text_formatter'
  module RSpec
    module Core
      module Formatters
        class BaseTextFormatter
          def dump_failure(example, index)
            output.puts "#{short_padding}#{index.next}) #{example.full_description}"
            puts "#{short_padding}Sauce public job link: #{example.metadata[:sauce_public_link]}"
            dump_failure_info(example)
          end
        end
      end
    end
  end
rescue LoadError
  # User isn't using RSpec
end
