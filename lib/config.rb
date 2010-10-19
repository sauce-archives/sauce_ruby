require 'json'
require 'yaml'

module Sauce
  class Config
    attr_reader :opts
    DEFAULT_OPTIONS = {
        :host => "saucelabs.com",
        :port => 4444,
        :browser_url => "http://saucelabs.com",
        :os => "Linux",
        :browser => "firefox",
        :browser_version => "3.",
        :job_name => "Unnamed Ruby job"
    }

    def initialize(opts={})
      @opts = DEFAULT_OPTIONS.merge(load_options_from_yaml)
      @opts.merge! load_options_from_environment
      @opts.merge! opts
    end

    def method_missing(meth, *args)
      return @opts[meth]
    end

    def to_browser_string
      browser_options = {
        'username' => @opts[:username],
        'access-key' => @opts[:access_key],
        'os' => @opts[:os],
        'browser' => @opts[:browser],
        'browser-version' => @opts[:browser_version],
        'name' => @opts[:job_name]}
      return browser_options.to_json
    end

    private

    def load_options_from_environment
      opts = {}
      opts[:host] = ENV['SAUCE_HOST']
      opts[:port] = ENV['SAUCE_PORT']
      opts[:browser_url] = ENV['SAUCE_BROWSER_URL']

      opts[:username] = ENV['SAUCE_USERNAME']
      opts[:access_key] = ENV['SAUCE_ACCESS_KEY']

      opts[:os] = ENV['SAUCE_OS']
      opts[:browser] = ENV['SAUCE_BROWSER']
      opts[:browser_version] = ENV['SAUCE_BROWSER_VERSION']
      opts[:job_name] = ENV['SAUCE_JOB_NAME']

      opts[:firefox_profile_url] = ENV['SAUCE_FIREFOX_PROFILE_URL']
      opts[:user_extensions_url] = ENV['SAUCE_USER_EXTENSIONS_URL']

      return opts.delete_if {|key, value| value.nil?}
    end

    def load_options_from_yaml
        paths = [
            "ondemand.yml",
            File.join("config", "ondemand.yml"),
            File.join(ENV['HOME'], ".ondemand.yml")
        ]

        paths.each do |path|
            if File.exists? path
                conf = YAML.load_file(path)
                return conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
            end
        end
        return {}
    end
  end
end
