module Sauce
  module Utilities
    class Connect
      class TunnelNeverStarted < StandardError
      end

      TIMEOUT = 90 # Magic Numbers!

      def self.start_from_config(config)
        self.start(:host => config[:application_host], :port => config[:application_port], :quiet => true)
      end

      def self.start(options={})
        begin
          require "sauce/connect"
        rescue LoadError => e
          STDERR.puts 'Please install the `sauce-connect` gem if you intend on using Sauce Connect with your tests!'
          exit(1)
        end

        options[:timeout] = TIMEOUT unless options[:timeout]
        if ParallelTests.first_process?
          unless @tunnel
            @tunnel = Sauce::Connect.new options
            @tunnel.connect
            @tunnel.wait_until_ready
          end
          @tunnel
        else
          timeout_after = Time.now + options[:timeout]
          # Ensure first process has a change to start up
          sleep 5
          until (Time.now > timeout_after) || readyfile_found
            readyfile_found = File.exist? "sauce_connect.ready"
            sleep 1
          end

          raise(TunnelNeverStarted, "Sauce Connect was not started within #{TIMOUT} seconds") unless readyfile_found
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

      class << self
        attr_reader :tunnel
      end
    end
  end
end