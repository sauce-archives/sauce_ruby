require 'timeout'
require 'socket'
require 'childprocess'
require 'net/http'
require 'childprocess/process'
require 'sauce/parallel'

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

    class RailsServer
      include Sauce::Utilities

      def self.is_rails_app?
        File.exists?('script/server') || File.exists?('script/rails')
      end

      def start
        port = 3001

        if ENV["TEST_ENV_NUMBER"]
          @test_env = ENV["TEST_ENV_NUMBER"].to_i
          port = port + @test_env
        end

        STDERR.puts "Starting Rails server on port #{port}..."

        if File.exists?('script/server')
          @process_args = ["ruby", "script/server", "-e", "test", "--port", "#{port}"]
          #@server = ChildProcess.build("ruby", "script/server", "-e", "test", "--port", "#{port}")
        elsif File.exists?('script/rails')
          @process_args = ["bundle", "exec", "rails", "server", "-e", "test", "--port", "#{port}"]
          #@server = ChildProcess.build("bundle", "exec", "rails", "server", "-e", "test", "--port", "#{port}")
        end

        if @test_env
          @process_args.push *["--pid", "#{Dir.pwd}/tmp/pids/server-#{@test_env}"]
        end

        @server = ChildProcess.build *@process_args
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
