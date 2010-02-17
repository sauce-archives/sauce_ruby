module Sauce
  # Interact with a Sauce Labs tunnel as if it were a ruby object
  class Tunnel
    class NoIDError < StandardError; end #nodoc

    attr_accessor :client, :application_address, :username, :access_key, :timeout
    attr_accessor :status, :owner, :creation_time, :id, :host

    def initialize(client, options)
      @client = client
      build!(options)
    end

    # Hits the destroy url for this tunnel, and then refreshes. Keep in mind it takes some time to completely teardown a tunnel.
    def destroy
      response = @client["tunnels/#{@id}"].delete
      refresh!
    end

    # Retrieves the latest information on this tunnel from the Sauce Labs' server
    def refresh!
      response = JSON.parse @client["tunnels/#{@id}"].get
      build! response
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
