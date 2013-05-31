require 'timeout'
require 'socket'
require 'childprocess'
require 'net/http'
require 'childprocess/process'

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

        port = 3001
        if ENV["TEST_ENV_NUMBER"]
          port = port + ENV["TEST_ENV_NUMBER"].to_i
        end

        if File.exists?('script/server')
          @server = ChildProcess.build("ruby", "script/server", "-e", "test", "--port", "#{port}")
        elsif File.exists?('script/rails')
          @server = ChildProcess.build("bundle", "exec", "rails", "server", "-e", "test", "--port", "#{port}")
        end
        @server.io.inherit!
        @server.start

        wait_for_server_on_port(port)

        at_exit do
          @server.stop(3, "INT")
        end
        STDERR.puts "Rails server running!"
      end

      def stop
        begin
          @server.stop(3, "INT")
        rescue
          STDERR.puts "Rails server could not be killed. Did it fail to start?"
        end
      end
    end
  end
end
