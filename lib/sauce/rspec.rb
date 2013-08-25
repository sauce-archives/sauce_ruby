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
            Sauce::Utilities::Connect.start_from_config(config)
          end

          @@server = Sauce::Utilities::RailsServer.start_if_required(config)
        end

        ::RSpec.configuration.before :suite do
          config = Sauce::Config.new
          # TODO: Check which rspec version this changed in -- If < 2, change.
          files_to_run = ::RSpec.configuration.respond_to?(:files_to_run) ? ::RSpec.configuration.files_to_run :
            ::RSpec.configuration.settings[:files_to_run]

          running_selenium_specs = files_to_run.any? {|file| file =~ /spec\/selenium\//}
          need_tunnel = running_selenium_specs && config[:application_host]

          if need_tunnel || config[:start_tunnel]
            Sauce::Utilities::Connect.start_from_config(config)
          end

          if running_selenium_specs
            @@server = Sauce::Utilities::RailsServer.start_if_required(config)
          end
        end

        ::RSpec.configuration.after :suite do
          Sauce::Utilities::Connect.close
          @@server.stop if @@server
        end
      end
    end
  end
rescue LoadError, TypeError
  # User doesn't have RSpec 2.x installed
rescue => e
  STDERR.puts "Exception caught: #{e.to_s}"
end