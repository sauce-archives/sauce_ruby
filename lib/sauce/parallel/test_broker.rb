require "rest-client"
require "json"
require "yaml"
require "sauce/parallel/test_group"
require "thread"

module Sauce
  class TestBroker

    def self.environment_mutex
      @@m ||= Mutex.new
    end

    def self.next_environment(group)
      environment_mutex.synchronize do
        browsers = {}
        group.each do |file|
          file = "./" + file
          test_groups[file] ||= TestGroup.new(self.test_platforms)
          browsers[file] ||= []
          browsers[file] << test_groups[file].next_platform
        end

        return {:SAUCE_PERFILE_BROWSERS => "'" + JSON.generate(browsers) + "'"}
      end
    end

    def self.test_groups
      @groups ||= {}
    end

    def self.test_groups=(groups)
      @groups = groups.reduce({}) do |hash, g|
        hash[g] = TestGroup.new(self.test_platforms)
        hash
      end

      @group_indexes = groups.uniq.reduce({}) do |rh, g|
        rh[g] =(groups.each_index.select {|i| groups[i] == g})
        rh
      end
    end

    def self.group_index(group)
      @group_indexes[group].shift
    end

    def self.test_platforms
      unless defined? @@platforms
        load_sauce_config
        brokers = Sauce.get_config
        @@platforms ||= brokers[:browsers]
      end
      @@platforms
    end

    def self.concurrencies
      response = RestClient.get "#{rest_jobs_url}/#{SAUCE_USERNAME}/limits"
      res = JSON.parse(response)["concurrency"]
    end

    def self.rest_jobs_url
      "https://#{AUTH_DETAILS}@saucelabs.com/rest/v1"
    end

    def self.load_sauce_config
      begin
        if File.exists? "./spec/sauce_helper.rb"
          require "./spec/sauce_helper"
        else
          require "./spec/spec_helper"
        end
      rescue LoadError => e
        # Gross, but maybe theyre using Cuke
        begin
          if File.exists? "./features/support/sauce_helper.rb"
            require "./features/support/sauce_helper"
          else
            raise LoadError "Can't find sauce_helper, please add it in ./features/support/sauce_helper.rb"
          end
        rescue LoadError => e
          #WHO KNOWS
        end
      end

    end

    SAUCE_USERNAME = ENV["SAUCE_USERNAME"]
    SAUCE_ACCESS_KEY = ENV["SAUCE_ACCESS_KEY"]
    AUTH_DETAILS = "#{SAUCE_USERNAME}:#{SAUCE_ACCESS_KEY}"
  end
end
