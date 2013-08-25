require 'childprocess'
require 'childprocess/process'

module Sauce
  module Utilities
    class RailsServer
      include Sauce::Utilities

      def self.start_if_required(config)
        if config[:start_local_application] && self.is_rails_app?
          server = self.start
        end

        return server
      end

      def self.is_rails_app?
        return !major_version.nil?
      end

      def self.major_version
        paths = ["script/server", "script/rails", "bin/rails"]
        startup_script = paths.detect {|path| File.exists? path}

        case startup_script
          when 'script/server'
            return 2
          when 'script/rails'
            return 3
          when 'bin/rails'
            return 4
          else
            return nil
        end
      end

      def self.process_arguments
        case major_version
          when 2
            ["ruby", "script/server"]
          else
            ["bundle", "exec", "rails", "server"]
        end
      end

      def self.server_pool
        @@server_pool ||= {}
      end

      attr_reader :port

      def start
        @port = Sauce::Config.new[:application_port]

        if ENV["TEST_ENV_NUMBER"]
          @test_env = ENV["TEST_ENV_NUMBER"].to_i
        end

        STDERR.puts "Starting Rails server on port #{@port}..."

        @process_args = RailsServer.process_arguments
        @process_args.push *["-e", "test", "--port", "#{@port}"]

        if @test_env
          @process_args.push *["--pid", "#{Dir.pwd}/tmp/pids/server-#{@test_env}"]
        end

        @server = ChildProcess.build *@process_args
        @server.io.inherit!
        @server.start

        wait_for_server_on_port(@port)

        at_exit do
          @server.stop(3, "INT")
          RailsServer.server_pool.delete Thread.current.object_id
        end
        STDERR.puts "Rails server running!"

        RailsServer.server_pool[Thread.current.object_id] = @server
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
