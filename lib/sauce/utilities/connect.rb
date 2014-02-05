module Sauce
  module Utilities
    class Connect
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

      class << self
        attr_reader :tunnel
      end
    end
  end
end