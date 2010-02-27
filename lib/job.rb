require 'net/telnet'
require 'net/ssh'
require 'net/ssh/gateway'
require 'gateway_ext'

module Sauce
  # Interact with a Sauce Labs selenium jobs as if it were a ruby object
  class Job

    #{"BrowserVersion": "3.", "Name": "prsel_./spec/integration/people_a_1_spec.rb", "_rev": "5-228269313", "CreationTime": 1266698090, "AssignmentTime": 1266698097, "Server": "10.212.146.145:4443", "AssignedTo": "f663372ba04444ce8cb3e6f61503f304", "ChefStartTime": 1266698101, "EndTime": 1266698139, "Type": "job", "Interactive": "true", "Status": "complete", "SeleniumServerLogUploadRequest": {"bucket": "sauce-userdata", "key": "sgrove/6337fe576deba0ba278dc1b5dfceac5f/selenium-server.log"}, "Tags": [], "ResultId": "6337fe576deba0ba278dc1b5dfceac5f", "AttachmentRequests": {}, "ModificationTime": 1266698139, "Browser": "firefox", "StartTime": 1266698101, "Owner": "sgrove", "_id": "01fc48caba6d15b46fad79e1b0562bbe", "OS": "Linux", "VideoUploadRequest": {"bucket": "sauce-userdata", "key": "sgrove/6337fe576deba0ba278dc1b5dfceac5f/video.flv"}}

    attr_accessor :owner, :id, :name, :_rev, :server, :assigned_to, :sauce_type, :interactive, :status,:tags, :result_id
    attr_accessor :selenium_server_log_upload_request, :attachment_requests, :videoupload_request
    attr_accessor :creation_time, :assignment_time, :chef_start_time, :end_time, :modification_time, :start_time
    attr_accessor :os, :browser, :browser_version

    # TODO: Buckets for logs and videos
    
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
=begin
      responses = JSON.parse @@client["jobs/recent"].get
      return responses.collect{|response| Sauce::Job.new(response)}
=end
      return self.complete_jobs + self.in_progress_jobs
    end

    def self.destroy
      self.all.each { |tunnel| tunnel.destroy }
    end

    def self.find id
      #puts "GET-URL: #{@@client.url}jobs/#{id}"
      Sauce::Job.new JSON.parse(@@client["jobs/#{id}"].get)
    end

    def self.complete_jobs
      responses = JSON.parse @@client["complete-jobs"].get
      start = Time.now
      jobs = responses["jobs"].collect{|response| Sauce::Job.find(response["id"])}
      lapsed = Time.now - start
      puts "Took #{lapsed} seconds"
      return jobs
    end

    def self.in_progress_jobs
      responses = JSON.parse @@client["in-progress-jobs"].get
      return [] if responses == []
      start = Time.now
      jobs = responses["jobs"].collect{|response| Sauce::Job.find(response["id"])}
      lapsed = Time.now - start
      puts "Took #{lapsed} seconds"
      return jobs
    end

    # Creates an instance representing a job.
    def initialize(options)
      build!(options)
    end

    # Retrieves the latest information on this job from the Sauce Labs' server
    def refresh!
      response = JSON.parse @@client["jobs/#{@id}"].get
      puts "\tjob refresh with: #{response.inspect}"
      build! response
      self
    end

    protected 

    # Sets all internal variables from a hash
    def build!(options)
      #puts "\tBuild  with #{options.inspect}"
      
      @owner       = options["Owner"]
      @id          = options["_id"]
      @id          = options["id"] if @id.nil? or @id.empty?
      @name        = options["Name"]
      @_rev        = options["_rev"]
      @server      = options["Server"]
      @assigned_to = options["AssignedTo"]

      @sauce_type  = options["Type"]
      @interactive = options["Interactive"]
      @status      = options["Status"]
      @tags        = options["Tags"]
      @result_id   = options["ResultId"]

      @os              = options["OS"]
      @browser         = options["Browser"]
      @browser_version = options["BrowserVersion"]

      # TODO: Should this be created_at and updated_at? Probably.
      @creation_time     = options["CreationTime"]
      @assignment_time   = options["AssignmentTime"]
      @chef_start_time   = options["ChefStartTime"]
      @end_time          = options["EndTime"]
      @modification_time = options["ModificationTime"]
      @start_time        = options["StartTime"]

      raise NoIDError if @id.nil? or @id.empty?
    end
  end
end
