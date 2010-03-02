require 'net/telnet'
require 'net/ssh'
require 'net/ssh/gateway'
require 'gateway_ext'

module Sauce
  # Interact with a Sauce Labs selenium jobs as if it were a ruby object
  class Job

    class CannotDeleteJobError < StandardError; end #:nodoc

    attr_accessor :id, :owner, :status, :error
    attr_accessor :name, :browser, :browser_version, :os
    attr_accessor :creation_time, :start_time, :end_time
    attr_accessor :public, :video_url, :log_url, :tags

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

    # Misnomer: Gets the most recent 100 jobs
    # TODO: Allow/automate paging
    def self.all(options={})
      responses = JSON.parse @@client["jobs/full"].get
      return responses.collect{|response| Sauce::Job.new(response)}
    end

    def self.destroy
      self.all.each { |tunnel| tunnel.destroy }
    end

    def self.find(options={})
      if options.class == String
        id = options
      elsif options.class == Hash
        id = options[:id]
      end
      
      #puts "GET-URL: #{@@client.url}jobs/#{id}"
      Sauce::Job.new JSON.parse(@@client["jobs/#{id}"].get)
    end

    # Creates an instance representing a job.
    def initialize(options)
      build!(options)
    end

    # Retrieves the latest information on this job from the Sauce Labs' server
    def refresh!
      response = JSON.parse @@client["jobs/#{@id}"].get
      #puts "\tjob refresh with: #{response}"
      build! response
      self
    end

    # Save/update the current information for the job
    def save
      response = JSON.parse(@@client["jobs/#{@id}"]. self.to_json, :content_type => :json, :accept => :json)
    end

    def self.to_json(options={})
      json = {
        :id =>              @id,
        :owner =>           @owner,
        :status =>          @status,
        :error =>           @error,
        :name =>            @name,
        :browser =>         @browser,
        :browser_version => @browser_version,
        :os =>              @os,
        :creation_time =>   @creation_time,
        :start_time =>      @start_time,
        :end_time =>        @end_time,
        :video_url =>       @video_url,
        :log_url =>         @log_url,
        :public =>          @public,
        :tags =>            @tags
      }

      options[:except].each { |key| json.delete(key) } if options[:except]
      json = json.select { |key,value| options[:only].include? key } if options[:only]
      
      return json
    end

    def delete
      raise CannonDeleteJobError("Cannot delete jobs via Sauce Labs'  REST API currently")
    end

    protected

    # Sets all internal variables from a hash
    def build!(options)
      @id              = options["id"]
      @owner           = options["owner"]
      @status          = options["status"]
      @error           = options["error"]
      @name            = options["name"]
      @browser         = options["browser"]
      @browser_version = options["browser_version"]
      @os              = options["os"]
      @creation_time   = options["creation_time"].to_i
      @start_time      = options["start_time"].to_i
      @end_time        = options["end_time"].to_i
      @video_url       = options["video_url"]
      @log_url         = options["log_url"]
      @public          = options["public"]
      @tags            = options["tags"]

      raise NoIDError if @id.nil? or @id.empty?
    end
  end
end
