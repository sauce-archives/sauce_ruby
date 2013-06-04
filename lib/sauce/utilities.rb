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

    class Connect

      def self.start(options={})
        begin
          require "sauce/connect"
        rescue LoadError => e
          STDERR.puts <<-ERROR
Please install the `sauce-connect` gem if you intend on using Sauce Connect with your tests!

If you don't wish to use Sauce Connect, set [:start_tunnel] to false:
  Sauce.config do |config|
    config[:start_tunnel] = false
  end
          ERROR
          exit(1)
        end

        unless @tunnel
          @tunnel = Sauce::Connect.new options
          @tunnel.connect
          @tunnel.wait_until_ready
        end
          @tunnel
      end

      def self.close
        if @tunnel
          @tunnel.disconnect
          @tunnel = nil
        end
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
