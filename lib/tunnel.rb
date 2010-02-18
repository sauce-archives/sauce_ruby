module Sauce
  # Interact with a Sauce Labs tunnel as if it were a ruby object
  class Tunnel
    class NoIDError < StandardError; end #nodoc

    attr_accessor :application_address, :username, :access_key, :timeout
    attr_accessor :status, :owner, :creation_time, :id, :host

    def self.create(options)
      response = JSON.parse @@client[:tunnels].post(options.to_json, :content_type => 'application/json')
      Tunnel.new response
    end

    def initialize(options)
      build!(options)
    end

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

    def self.first
      self.all.first
    end

    def self.last
      self.all.last
    end

    def self.all
      responses = JSON.parse @@client[:tunnels].get
      return responses.collect{|response| Sauce::Tunnel.new(response)}
    end

    def self.destroy
      self.all.each { |tunnel| tunnel.destroy }
    end

    # Hits the destroy url for this tunnel, and then refreshes. Keep in mind it takes some time to completely teardown a tunnel.
    def destroy
      response = @@client["tunnels/#{@id}"].delete
      refresh!
    end

    # Retrieves the latest information on this tunnel from the Sauce Labs' server
    def refresh!
      response = JSON.parse @@client["tunnels/#{@id}"].get
      build! response
    end

    # Sauce Labs' server will say hello on port 1025 as a sanity check. If no hello, something is wrong. TODO: Make it say hello on port 1025. Currently a hack.
    def says_hello?(options={})
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

    protected 

    # Sets all internal variables from a hash
    def build!(options)
      @status = options["Status"]
      @owner = options["Owner"]
      @id = options["_id"]
      @id = options["id"] if @id.nil? or @id.empty?
      @host = options["Host"]

      raise NoIDError if @id.nil? or @id.empty?
    end
  end
end
