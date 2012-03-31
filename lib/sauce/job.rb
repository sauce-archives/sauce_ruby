require 'sauce/client'

module Sauce
  # Interact with a Sauce Labs selenium jobs as if it were a ruby object
  class Job

    class CannotDeleteJobError < StandardError; end #:nodoc

    attr_accessor :id, :owner, :status, :error
    attr_accessor :name, :browser, :browser_version, :os
    attr_accessor :creation_time, :start_time, :end_time
    attr_accessor :public, :video_url, :log_url, :tags
    attr_accessor :passed

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
      url = "jobs"
      url += "?full=true" if options[:full] #unless options[:id_only]
      responses = @@client[url].get
      responses = JSON.parse responses.to_s
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

      @@client ||= Sauce::Client.new

      #puts "GET-URL: #{@@client.url}jobs/#{id}"
      response = @@client["jobs/#{id}"].get

      # TODO: Return nil if bad response
      Sauce::Job.new JSON.parse(response.to_s)
    end

    # Creates an instance representing a job.
    def initialize(options)
      build!(options)
    end

    # Retrieves the latest information on this job from the Sauce Labs' server
    def refresh!
      response = JSON.parse @@client["jobs/#{@id}"].get.body
      #puts "\tjob refresh with: #{response}"
      build! response
      self
    end

    # Save/update the current information for the job
    def save
      #puts "Saving job:\n -X PUT #{@@client['jobs']}/#{@id} -H 'Content-Type: application/json' -d '#{self.to_json}'"
      response = @@client["jobs/#{@id}"].put(self.to_json,
                                             {:content_type => :json,
                                               :accept => :json}).body
      JSON.parse(response)
    end

    def to_json(options={})
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
        :tags =>            @tags,
        :passed =>          @passed
      }

      options[:except].each { |key| json.delete(key) } if options[:except]
      json = json.select { |key,value| options[:only].include? key } if options[:only]

      return json.to_json
    end

    def delete
      raise CannonDeleteJobError("Cannot delete jobs via Sauce Labs'  REST API currently")
    end

    protected

    # Sets all internal variables from a hash
    def build!(options)
      #puts "\tBuild with: #{options.inspect}"
      # Massage JSON
      options.each { |key,value| options[key] = false if options[key] == "false" }

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
      @passed          = options["passed"]

      raise NoIDError if @id.nil? or @id.empty?
    end
  end
end
