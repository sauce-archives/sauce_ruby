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
          Sauce.logger.debug "Requiring Sauce Connect gem."
          require "sauce/connect"
        rescue LoadError => e
          STDERR.puts 'Please install the `sauce-connect` gem if you intend on using Sauce Connect with your tests!'
          exit(1)
        end

        options[:timeout] = TIMEOUT unless options[:timeout]
        if ParallelTests.first_process?
          Sauce.logger.debug "#{Thread.current.object_id} - First parallel process attempting to start Sauce Connect."
          unless @tunnel
            @tunnel = Sauce::Connect.new options
            @tunnel.connect
            @tunnel.wait_until_ready
          else
            Sauce.logger.warn "#{Thread.current.object_id} - Tunnel already existed somehow."
          end
          @tunnel
        else
          Sauce.logger.debug "#{Thread.current.object_id} - Waiting for a Sauce Connect tunnel to be ready."
          timeout_after = Time.now + options[:timeout]
          # Ensure first process has a change to start up
          sleep 5
          readyfile_found = File.exist? "sauce_connect.ready" 
          until (Time.now > timeout_after) || readyfile_found
            readyfile_found = File.exist? "sauce_connect.ready"
            sleep 1
          end

          raise(TunnelNeverStarted, "Sauce Connect was not started within #{TIMEOUT} seconds") unless readyfile_found
        end
      end

      def self.close
        if @tunnel
          if ParallelTests.first_process?
            Sauce.logger.debug "#{Thread.current.object_id} - First parallel process waiting for other processes before closing Sauce Connect."
            ParallelTests.wait_for_other_processes_to_finish
            Sauce.logger.debug "#{Thread.current.object_id} - All other parallel processes closed - Closing Sauce Connect tunnel #{@tunnel}."
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