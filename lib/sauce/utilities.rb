require 'timeout'
require 'socket'
require 'net/http'
require 'sauce/parallel'
require 'sauce/utilities/rails_server'
require 'sauce/utilities/connect'

module Sauce
  module Utilities
    def silence_stream(stream)
      old_stream = stream.dup
      stream.reopen(RUBY_PLATFORM =~ /mswin/ ? 'NUL:' : '/dev/null')
      stream.sync = true
      yield
    ensure
      stream.reopen(old_stream)
    end

    def wait_for_server_on_port(port)
      while true
        begin
          Timeout::timeout(2) do
              socket = TCPSocket.new('127.0.0.1', port)
              socket.close unless socket.nil?
              return
          end
        rescue Errno::ECONNREFUSED,
          Errno::EBADF,           # Windows
          Timeout::Error
        end
        sleep 2
      end
    end

    def self.warn_if_suspect_misconfiguration(style = :rspec)
      if Sauce::Selenium2.used_at_least_once?
        integrated = Sauce::Config.called_from_integrations?
        warnings_on = Sauce::Config.new[:warn_on_skipped_integration]
        unless (integrated && warnings_on)
          STDERR.puts Sauce::Utilities.incorrectly_integrated_warning(style)
        end
      end
    end

    def self.page_deprecation_message
      return <<-MESSAGE
[DEPRECATED] Using the #page method is deprecated for RSpec tests without Capybara.  Please use the #s or #selenium method instead.
If you are using Capybara and are seeing this message, check the Capybara README for information on how to include the Capybara DSL in your tests.
      MESSAGE
    end

    def self.incorrectly_integrated_warning(style = :rspec)
      case style
        when :cuke
          tests = 'features'
          runner = 'Cucumber'
          tag = '@selenium'
        else :rspec
          tests = 'specs'
          runner = 'RSpec'
          tag = ':sauce => true'
      end

      return <<-stringend

===============================================================================
Your #{tests} used the Sauce Selenium driver, but not the #{runner} integration.
This may result in undesired behaviour, such as configured platforms being
skipped.

You can correct this by tagging #{tests} intended for Sauce with
'#{tag}'.

You can disable this message by setting the 'warn_on_skipped_integration'
config option to false.
===============================================================================
      stringend
    end
  end
end
