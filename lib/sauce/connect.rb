module Sauce
  class Connect
    TIMEOUT = 300

    attr_reader :status, :error

    def initialize(options={})
      @ready = false
      @status = "uninitialized"
      @error = nil
      host = options[:host] || '127.0.0.1'
      port = options[:port] || '3000'
      tunnel_port = options[:tunnel_port] || '80'
      options.delete(:host)
      options.delete(:port)
      options.delete(:tunnel_port)
      config = Sauce::Config.new(options)
      if config.username.nil?
        raise ArgumentError, "Username required to launch Sauce Connect. Please set the environment variable $SAUCE_USERNAME"
      end
      if config.access_key.nil?
        raise ArgumentError, "Access key required to launch Sauce Connect. Please set the environment variable $SAUCE_ACCESS_KEY"
      end
      args = ['-u', config.username, '-k', config.access_key, '-s', host, '-p', port, '-d', config.domain, '-t', tunnel_port]
      @pipe = IO.popen((["exec", "\"#{Sauce::Connect.find_sauce_connect}\""] + args + ["2>&1"]).join(' '))
      @process_status = $?
      at_exit do
        Process.kill("INT", @pipe.pid)
        while @ready
          sleep 1
        end
      end
      Thread.new {
        while( (line = @pipe.gets) )
          if line =~ /Tunnel host is (.*) (\.\.|at)/
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
            options[:quiet] = false
          end
          $stderr.puts line unless options[:quiet]
        end
        @ready = false
      }
    end

    def wait_until_ready
      start = Time.now
      while !@ready and (Time.now-start) < TIMEOUT and @error != "Missing requirements"
        sleep 0.4
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
      File.join(File.dirname(File.dirname(File.expand_path(File.dirname(__FILE__)))), "support", "sauce_connect")
    end

    # Global Sauce Connect-ness
    @connection = nil

    def self.connect!(*args)
      @connection = self.new(*args)
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
