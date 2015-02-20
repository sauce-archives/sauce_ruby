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
