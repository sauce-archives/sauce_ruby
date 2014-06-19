require "rest-client"
require "json"
require "yaml"
require "sauce/parallel/test_group"
require "thread"

module Sauce
  class TestBroker
    POSSIBLE_CONFIGURATION_FILES = ["./spec/sauce_helper.rb", "./spec/spec_helper.rb", "./features/support/sauce_helper.rb"]

    def self.reset
      if defined? @@platforms
        remove_class_variable(:@@platforms)
      end
      @groups = {}
    end

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

        on_windows = RbConfig::CONFIG['host_os'] =~ /cygwin|mswin|mingw|bccwin|wince|emx/
        format_string = on_windows ? "%s" : "'%s'"
        perfile_browsers = format_string % [JSON.generate(browsers)]

        return {:SAUCE_PERFILE_BROWSERS => perfile_browsers}
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
        @@platforms ||= Sauce.get_config[:browsers]
      end
      @@platforms
    end

    def self.concurrency
      response = RestClient.get "#{rest_jobs_url}/#{SAUCE_USERNAME}/limits"
      res = JSON.parse(response)["concurrency"]
    end

    def self.rest_jobs_url
      "https://#{AUTH_DETAILS}@saucelabs.com/rest/v1"
    end

    def self.load_sauce_config
      configuration_file = POSSIBLE_CONFIGURATION_FILES.find { |file_path| File.exists?(file_path) }
      if configuration_file
        require configuration_file
      else
        error_message = "Could not find Sauce configuration. Please make sure one of the following files exists:\n"
        error_message << POSSIBLE_CONFIGURATION_FILES.map { |file_path| "  - #{file_path}" }.join("\n")
        raise error_message
      end
    end

    SAUCE_USERNAME = ENV["SAUCE_USERNAME"]
    SAUCE_ACCESS_KEY = ENV["SAUCE_ACCESS_KEY"]
    AUTH_DETAILS = "#{SAUCE_USERNAME}:#{SAUCE_ACCESS_KEY}"
  end
end
