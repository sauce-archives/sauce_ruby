require 'timeout'
require 'socket'
require 'childprocess'
require 'net/http'
require 'childprocess/process'
require 'sauce/parallel'
require 'sauce/utilities/rails_server'

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


    class Connect
      def self.start(options={})
        begin
          require "sauce/connect"
        rescue LoadError => e
          STDERR.puts 'Please install the `sauce-connect` gem if you intend on using Sauce Connect with your tests!'
          exit(1)
        end

        if ParallelTests.first_process?
          unless @tunnel
            @tunnel = Sauce::Connect.new options
            @tunnel.connect
            @tunnel.wait_until_ready
          end
          @tunnel
        else
          while not File.exist? "sauce_connect.ready"
            sleep 0.5
          end
        end
      end

      def self.close
        if @tunnel
          if ParallelTests.first_process?
            ParallelTests.wait_for_other_processes_to_finish
            @tunnel.disconnect
            @tunnel = nil
          end
        end
      end
    end
  end
end
