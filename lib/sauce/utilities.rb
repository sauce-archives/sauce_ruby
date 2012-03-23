require 'timeout'
require 'socket'
require 'childprocess'
require 'net/http'

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

    class RailsServer
      include Sauce::Utilities

      def self.is_rails_app?
        File.exists?('script/server') || File.exists?('script/rails')
      end

      def start
        STDERR.puts "Starting Rails server on port 3001..."
        if File.exists?('script/server')
          @server = ChildProcess.build("ruby", "script/server", "-e", "test", "--port", "3001")
        elsif File.exists?('script/rails')
          @server = ChildProcess.build("bundle", "exec", "rails", "server", "-e", "test", "--port", "3001")
        end
        @server.io.inherit!
        @server.start

        wait_for_server_on_port(3001)

        at_exit do
          @server.stop
        end
        STDERR.puts "Rails server running!"
      end

      def stop
        begin
          @server.stop
        rescue
          STDERR.puts "Rails server could not be killed. Did it fail to start?"
        end
      end
    end
  end
end
