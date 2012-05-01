require 'sauce/config'

module Sauce
  class Connect
    TIMEOUT = 90

    attr_reader :status, :error

    def initialize(options={})
      @ready = false
      @status = "uninitialized"
      @error = nil
      @quiet = options[:quiet]
      host = options[:host] || '127.0.0.1'
      port = options[:port] || '3000'
      tunnel_port = options[:tunnel_port] || '80'
      options.delete(:host)
      options.delete(:port)
      options.delete(:tunnel_port)
      @config = Sauce::Config.new(options)
      if @config.username.nil?
        raise ArgumentError, "Username required to launch Sauce Connect. Please set the environment variable $SAUCE_USERNAME"
      end
      if @config.access_key.nil?
        raise ArgumentError, "Access key required to launch Sauce Connect. Please set the environment variable $SAUCE_ACCESS_KEY"
      end
    end

    def connect
      puts "[Connecting to Sauce OnDemand...]"
      @pipe = IO.popen("exec #{Sauce::Connect.connect_command} #{@config.username} #{@config.access_key} 2>&1")
      @process_status = $?
      at_exit do
        Process.kill("INT", @pipe.pid)
        while @ready
          sleep 1
        end
      end
      Thread.new {
        while( (line = @pipe.gets) )
          if line =~ /Tunnel remote VM is (.*) (\.\.|at)/
            @status = $1
          end
          if line =~/You may start your tests\./
            @ready = true
          end
          if line =~ /- (Problem.*)$/
            @error = $1
          end
          if line =~ /== Missing requirements ==/
            @error = "Missing requirements"
            @quiet = false
          end
          $stderr.puts line unless @quiet
        end
        @ready = false
      }
    end

    def wait_until_ready
      start = Time.now
      while !@ready and (Time.now-start) < TIMEOUT and @error != "Missing requirements"
        sleep 0.5
      end

      if @error == "Missing requirements"
        raise "Missing requirements"
      end

      if !@ready
        raise "Sauce Connect failed to connect after #{TIMEOUT} seconds"
      end
    end

    def disconnect
      if @ready
        Process.kill("INT", @pipe.pid)
        while @ready
          sleep 1
        end
      end
    end

    def self.find_sauce_connect
      File.expand_path(File.dirname(__FILE__) + '/../../support/Sauce-Connect.jar')
    end

    def self.connect_command
      "java -jar #{Sauce::Connect.find_sauce_connect}"
    end

    # Global Sauce Connect-ness
    @connection = nil

    def self.connect!(*args)
      @connection = self.new(*args)
      @connection.connect
      @connection.wait_until_ready
      at_exit do
        @connection.disconnect
      end
    end

    def self.ensure_connected(*args)
      if @connection
        @connection.wait_until_ready
      else
        connect!(*args)
      end
    end
  end
end
