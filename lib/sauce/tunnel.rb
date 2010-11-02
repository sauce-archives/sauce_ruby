# NOTE: This has been superseded by sauce/connect. Consider for deprecation

require 'net/telnet'
require 'net/ssh'
require 'net/ssh/gateway'
require 'sauce/gateway_ext'

module Sauce
  # Interact with a Sauce Labs tunnel as if it were a ruby object
  class Tunnel
    class NoIDError < StandardError; end #nodoc

    #{"Status": "running", "CreationTime": 1266545716, "ModificationTime": 1266545793, "Host": "ec2-184-73-16-13.compute-1.amazonaws.com", "LaunchTime": 1266545726, "Owner": "sgrove", "_id": "1090b4b0b50477cf40fc44c146b408a4", "Type": "tunnel", "id": "1090b4b0b50477cf40fc44c146b408a4", "DomainNames": ["sgrove.tst"]}

    attr_accessor :owner, :access_key, :status
    attr_accessor :id, :host, :domain_names, :timeout
    attr_accessor :launch_time, :created_at, :updated_at
    
    attr_accessor :application_address, :gateway, :port, :thread

    # Get the class @@client.
    # TODO: Consider metaprogramming this away
    def self.client
      @@client
    end

    # Set the class @@client.
    # TODO: Consider metaprogramming this away
    def self.client=(client)
      @@client = client
    end

    # Get the class @@client.
    # TODO: Consider metaprogramming this away
    def self.account
      @@account
    end

    # Set the class @@client.
    # TODO: Consider metaprogramming this away
    def self.account=(account)
      @@account = account
    end

    def self.first
      self.all.first
    end

    def self.last
      self.all.last
    end

    def self.all
      responses = JSON.parse @@client[:tunnels].get.body
      return responses.collect{|response| Sauce::Tunnel.new(response)}
    end

    def self.destroy_all
      self.all.each { |tunnel| tunnel.destroy }
    end

    # Creates a new tunnel machine
    def self.create(options)
      response = JSON.parse @@client[:tunnels].post(options.to_json, :content_type => 'application/json').body
      #puts response.inspect
      Tunnel.new response
    end

    # Creates an instance representing a machine, but does not actually create the machine. See #create for that.
    def initialize(options)
      build!(options)
    end

    # Hits the destroy url for this tunnel, and then refreshes. Keep in mind it takes some time to completely teardown a tunnel.
    def destroy
      close_gateway
      response = @@client["tunnels/#{@id}"].delete.body
      refresh!
    end

    # Retrieves the latest information on this tunnel from the Sauce Labs' server
    def refresh!
      response = JSON.parse @@client["tunnels/#{@id}"].get.body
      #puts "\Tunnel refresh with: #{response.inspect}"
      build! response
      self
    end

    # Shortcut method to find out if a tunnel is marked as dead
    def preparing?
      refresh!
      status == "new" or status == "booting"
    end

    # Shortcut method to find out if a tunnel is marked as dead
    def halting?
      refresh!
      status == "halting"
    end

    # Shortcut method to find out if a tunnel is marked as dead
    def terminated?
      refresh!
      status == "terminated"
    end

    # A tunnel is healthy if 1.) its status is "running" and 2.) It says hello
    def healthy?
      # TODO: Implement 3.) We can reach through and touch a service on the reverse end of the tunnel
      refresh!
=begin
      puts "\tRunning? #{self.status == 'running'}"
      puts "\tSays hello? #{self.says_hello?}"
      puts "\tThread running? #{self.still_running?}"
=end
      return true if not self.terminated? and self.status == "running" and self.says_hello? and self.still_running?
      return false
    end

    # Sauce Labs' server will say hello on port 1025 as a sanity check. If no hello, something is wrong.
    # TODO: Make it say hello on port 1025. Currently a hack.
    def says_hello?(options={})
      return false unless self.status == "running" and not @host.nil?

      # TODO: Read from options if necessary
      connection = {}
      connection[:host]        = @host
      connection[:port]        = 22
      connection[:prompt]      = /[$%#>] \z/n
      connection[:telnet_mode] = true
      connection[:timeout]     = 10

      host = Net::Telnet::new("Host"       => connection[:host],
                              "Port"       => connection[:port],
                              "Prompt"     => connection[:prompt],
                              "Telnetmode" => connection[:telnet_mode],
                              "Timeout"    => connection[:timeout])
      line = host.lines.first.chomp

      # Temporary workaround port 1025 problem
      prefix = "SSH-2.0-Twisted"
      line[0,prefix.length] == prefix
    end

    # Debug method
    def mini_repair
      refresh!
      if not self.terminated? and self.status == "running" and self.says_hello?
        if not self.still_running?
          open_gateway
          return true if self.still_running?
        end
      end
      return false
    end

    # Opens a reverse ssh tunnel to the tunnel machine
    def open_gateway
      # TODO: Make ports configurable

      @gateway = Net::SSH::Gateway.new(host, owner, {:password => @@account[:access_key]})

      # Notes for anyone looking at this method
      # gateway.open_remote(3000,        # Port where your local application is running. Usually 3000 for rails dev
      #                     "localhost", # Hostname/local ip your rails app is running on. Usually "localhost" for rails dev
      #                     80,          # This is the port to run your selenium tests against, i.e. :url => "http://<some_host>:80"
      #                                  #   <some_host> is the DomainNames you started the tunnel machine with.
      #                     "0.0.0.0")   # Do not change this unless your god has commanded you to do so. I'm serious.
      port = 3000
      local_host = "localhost"
      remote_port = 80
      #puts "This is the experimental non-blocking gateway_open. Well done."
      #puts "gateway.open_remote(#{port}, #{local_host}, #{remote_port}, 0.0.0.0)"
      #gateway.open_remote(pair[0], local_host, pair[1], "0.0.0.0") do |rp, rh|

      @thread = Thread.new(host, port, remote_port, owner, @@account[:access_key]) do
        Thread.pass
        @gateway.open_remote(3000,
                             "localhost",
                             80,
                             "0.0.0.0") do |rp, rh|
          while true do
            sleep 10
          end
        end
      end

      @thread.run
    end

    # Closes the reverse ssh tunnel if open
    def close_gateway
      @thread.kill if @thread
    end

    # Returns true if this tunnel has a thread that needs to be monitored
    def still_running?
      #puts "\t\t#{@thread.inspect}.nil?"
      not @thread.nil?
    end

    # Returns a json representation of the current state of the tunnel object
    def to_json(options={})
      json = {
        :id =>              @id,
        :owner =>           @owner,
        :status =>          @status,
        :host =>            @host,
        :creation_time =>   @creation_time,
        :start_time =>      @start_time,
        :end_time =>        @end_time,
        :domain_name =>     @domain_names
      }

      options[:except].each { |key| json.delete(key) } if options[:except]
      json = json.select { |key,value| options[:only].include? key } if options[:only]
      
      return json
    end

    protected 

    # Sets all internal variables from a hash
    def build!(options)
      options = options["tunnel"] unless options["tunnel"].nil?
      #puts "\tBuild with #{options.inspect}"
      @status = options["status"]
      @owner  = options["owner"]
      @id     = options["id"]
      @host   = options["host"]
      @creation_time = options["creation_time"]
      @start_time = options["start_time"]
      @end_time = options["end_time"]
      @domain_names = options["domain_names"]

      raise NoIDError if @id.nil?
    end
  end
end
