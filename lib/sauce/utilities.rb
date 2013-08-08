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

    def self.page_deprecation_message
      return <<-MESSAGE
[DEPRECATED] Using the #page method is deprecated for RSpec tests without Capybara.  Please use the #s or #selenium method instead.
If you are using Capybara and are seeing this message, check the Capybara README for information on how to include the Capybara DSL in your tests.
      MESSAGE
    end
  end
end
