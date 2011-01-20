module Sauce
  class Connect
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
      args = ['-u', config.username, '-k', config.access_key, '-s', host, '-p', port, '-d', config.domain, '-t', tunnel_port]
      @pipe = IO.popen(([Sauce::Connect.find_sauce_connect] + args).join(' '))
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
          if line =~/You may start your tests/
            @ready = true
          end
          if line =~ /- (Problem.*)$/
            @error = $1
          end
          puts line unless options[:quiet]
        end
        @ready = false
      }
    end

    def wait_until_ready
      while(!@ready)
        sleep 0.4
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
  end
end
