require "rest-client"
require "json"
require "yaml"
require "sauce/parallel/test_group"
require "thread"

module Sauce
  class TestBroker
    CUCUMBER_CONFIG_FILES = ["./features/support/sauce_helper.rb"]
    RSPEC_CONFIG_FILES = ["./spec/sauce_helper.rb", "./spec/spec_helper.rb"]

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

    def self.test_platforms(tool=:rspec)
      unless defined? @@platforms
        load_sauce_config(tool)
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

    def self.load_sauce_config(tool=:rspec)
      case tool
        when :rspec
          primary_files = RSPEC_CONFIG_FILES
          secondary_files = CUCUMBER_CONFIG_FILES
        when :cucumber
          primary_files = CUCUMBER_CONFIG_FILES
          secondary_files = RSPEC_CONFIG_FILES
      end

      configuration_file = self.find_config_file(primary_files, secondary_files)
      unless configuration_file
        possible_config_files = primary_files + secondary_files
        error_message = "Could not find Sauce configuration. Please make sure one of the following files exists:\n"
        error_message << possible_config_files.map { |file_path| "  - #{file_path}" }.join("\n")
        raise error_message
      end
      Sauce.logger.info "Reading configuration from #{configuration_file}"
      require configuration_file
    end

    def self.find_config_file(primary_files, secondary_files)
      find_in_file_list(primary_files) || find_in_file_list(secondary_files)
    end

    def self.find_in_file_list(list)
      list.find { |file_path| File.exists?(file_path) }
    end

    SAUCE_USERNAME = ENV["SAUCE_USERNAME"]
    SAUCE_ACCESS_KEY = ENV["SAUCE_ACCESS_KEY"]
    AUTH_DETAILS = "#{SAUCE_USERNAME}:#{SAUCE_ACCESS_KEY}"
  end
end
