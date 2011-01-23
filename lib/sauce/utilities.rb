require 'timeout'
require 'socket'
require 'childprocess'
require 'net/http'

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

    def with_selenium_rc
      ENV['LOCAL_SELENIUM'] = "true"
      STDERR.puts "Starting Selenium RC server on port 4444..."

      jar_file = File.expand_path(File.dirname(__FILE__) + "/../../support/selenium-server.jar")
      command = ["java", "-jar", jar_file, "-port", "4444"]
      server = ChildProcess.build(*command)
      server.start
      wait_for_server_on_port(4444)
      STDERR.puts "Selenium RC running!"
      begin
        yield
      ensure
        Net::HTTP.get("127.0.0.1", "/selenium-server/driver/?cmd=shutDownSeleniumServer", 4444)
      end
    end

    def with_rails_server
      STDERR.puts "Starting Rails server on port 3001..."
      if File.exists?('script/server')
        server = IO.popen("ruby script/server -e test --port 3001 --daemon")
      elsif File.exists?('script/rails')
        server = IO.popen("script/rails server -p 3001 -e test")
      end

      wait_for_server_on_port(3001)
      STDERR.puts "Rails server running!"
      begin
        yield
      ensure
        begin
          pid = IO.read(File.join('tmp', 'pids', 'server.pid')).to_i
          Process.kill("INT", pid)
        rescue
          STDERR.puts "Rails server could not be killed. Is the pid in #{File.join('tmp', 'pids', 'server.pid')}?"
        end
      end
    end
  end
end
