require "rest-client"
require "json"
require "yaml"
require "sauce/parallel/test_group"

module Sauce
  class TestBroker
   
    def self.next_environment(group)
      unless test_groups.has_key? group
        test_groups[group] = TestGroup.new(self.test_platforms)
      end

      test_groups[group].next_platform
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
      if File.exists? "./spec/sauce_helper.rb"
        require "./spec/sauce_helper"
      else
        require "./spec/spec_helper"
      end
    end

    SAUCE_USERNAME = ENV["SAUCE_USERNAME"]
    SAUCE_ACCESS_KEY = ENV["SAUCE_ACCESS_KEY"]
    AUTH_DETAILS = "#{SAUCE_USERNAME}:#{SAUCE_ACCESS_KEY}"
  end
end
