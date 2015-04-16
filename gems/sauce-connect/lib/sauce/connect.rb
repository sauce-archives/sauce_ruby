require 'sauce/config'
require 'net/http'
require 'socket'

module Sauce
  class Connect
    class TunnelNotPossibleException < StandardError
    end

    TIMEOUT = 90

    attr_reader :status, :error

    def initialize(options={})
      @ready = false
      @status = "uninitialized"
      @error = nil
      @quiet = options[:quiet]
      @timeout = options.fetch(:timeout) { TIMEOUT }
      @config = Sauce::Config.new(options)
      @skip_connection_test = @config[:skip_connection_test]
      @cli_options = @config[:connect_options]
      @sc4_executable = @config[:sauce_connect_4_executable]

      if @config.username.nil?
        raise ArgumentError, "Username required to launch Sauce Connect. Please set the environment variable $SAUCE_USERNAME"
      end

      if @config.access_key.nil?
        raise ArgumentError, "Access key required to launch Sauce Connect. Please set the environment variable $SAUCE_ACCESS_KEY"
      end
    end

    def ensure_connection_is_possible
      $stderr.puts "[Checking REST API is contactable...]" unless @quiet
      uri = URI("http://saucelabs.com/rest/v1/#{@config[:username]}/tunnels")
      
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        request = Net::HTTP::Get.new uri.request_uri
        request.basic_auth(@config[:username], @config[:access_key])
        response = http.request request
      end

      unless response.kind_of? Net::HTTPOK
        $stderr.puts Sauce::Connect.cant_access_rest_api_message
        raise TunnelNotPossibleException, "Couldn't access REST API"
      end

      begin
        $stderr.puts "[Checking port 443 is open...]" unless @quiet
        socket = TCPSocket.new 'saucelabs.com', 443
      rescue SystemCallError => e
        raise e unless e.class.name.start_with? 'Errno::'
        $stderr.puts Sauce::Connect.port_not_open_message
        raise TunnelNotPossibleException, "Couldn't use port 443"
      end

    end

    def connect
      unless @skip_connection_test
        ensure_connection_is_possible
      end

      if java_is_present?
        puts "[Sauce Connect is connecting to Sauce Labs...]"

        formatted_cli_options = array_of_formatted_cli_options_from_hash(cli_options)

        command_args = []
        if @sc4_executable
          command_args = ['-u', @config.username, '-k', @config.access_key]
        else
          command_args = [@config.username, @config.access_key]
        end

        command_args << formatted_cli_options
        command = "exec #{connect_command} #{command_args.join(' ')} 2>&1"

        unless @quiet
          string_arguments = formatted_cli_options.join(' ')
          puts "[Sauce Connect arguments: '#{string_arguments}' ]"
        end

        @pipe = IO.popen(command)

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
            if line =~/You may start your tests\./i
              @ready = true
            end
            if line =~ /- (Problem.*)$/
              @error = $1
              @quiet = false
            end
            if line =~ /== Missing requirements ==/
              @error = "Missing requirements"
              @quiet = false
            end
            if line =~/Invalid API_KEY provided/
              @error = "Invalid API_KEY provided"
              @quiet = false
            end
            $stderr.puts line unless @quiet
          end
          @ready = false
        }
      else
        raise "Java doesn't seem to be installed.  Sauce Connect requires a working install of Java to proceed."
      end
    end

    def cli_options
      cli_options = { readyfile: "sauce_connect.ready" }
      cli_options.merge!(@cli_options) if @cli_options
      cli_options
    end

    def wait_until_ready
      start = Time.now
      while !@ready and (Time.now-start) < @timeout and @error != "Missing requirements"
        sleep 0.5
      end

      if @error == "Missing requirements"
        raise "Missing requirements"
      end

      if !@ready
        error_message = "Sauce Connect failed to connect after #{@timeout} seconds"
        error_message << "\n(Using Sauce Connect at #{@sc4_executable}" if @sc4_executable
        raise error_message
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

    # Check the absolute version of the provided path.
    # Returns true only if the path exists and is executable by the
    # effective current user.
    def find_sauce_connect
      if @sc4_executable and path_is_connect_executable? @sc4_executable
        File.absolute_path @sc4_executable
      else
        File.expand_path(File.dirname(__FILE__) + '/../../support/Sauce-Connect.jar')
      end
    end

    def connect_command
      command = "#{command_prefix}#{find_sauce_connect}"
      return command
    end

    # SC4 doesn't require a prefix
    def command_prefix
      @sc4_executable ? '' : 'java -jar '
    end

    def path_is_connect_executable? path
      absolute_path = File.absolute_path path
      if File.exist? absolute_path
        if File.executable? absolute_path
          true
        else
          raise TunnelNotPossibleException, "#{absolute_path} is not executable by #{Process.euid}"
        end
      else
        raise TunnelNotPossibleException, "#{absolute_path} does not exist"
      end
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

    private

    def array_of_formatted_cli_options_from_hash(hash)
      hash.collect do |key, value|
        opt_name = key.to_s.gsub("_", "-")
        
        if !@sc4_executable
          "--#{opt_name}=#{value}"
        else
          "--#{opt_name} #{value}"
        end
      end
    end

    def java_is_present?
      # This is nieve;  Can we be better?
      system 'java -version'
    end

    def self.port_not_open_message
      <<-ENDLINE
        Unable to connect to port 443 on saucelabs.com, which may interfere with
        Sauce Connect.

        This might be caused by a HTTP mocking framework like WebMock or 
        FakeWeb.  Check out 
        (https://github.com/saucelabs/sauce_ruby#network-mocking) 
        if you're using one.  Sauce Connect needs access to *.saucelabs.com,
        port 80 and port 443.

        You can disable network tests by setting :skip_connection_test to true in
        your Sauce.config block.
      ENDLINE
    end

    def self.cant_access_rest_api_message
      <<-ENDLINE
        Unable to connect to the Sauce REST API, which may interfere with
        Sauce Connect.

        This might be caused by a HTTP mocking framework like WebMock or 
        FakeWeb.  Check out 
        (https://github.com/saucelabs/sauce_ruby#network-mocking) 
        if you're using one.  Sauce Connect needs access to *.saucelabs.com,
        port 80 and port 443.
        
        You can disable network tests by setting :skip_connection_test to true in
        your Sauce.config block.
      ENDLINE
    end
  end
end
