require 'json'
require 'yaml'
require 'uri'

module Sauce
  def self.config
    @cfg = Sauce::Config.new(false)
    yield @cfg
  end

  def self.get_config
    @cfg
  end

  class Config
    attr_reader :opts

    DEFAULT_OPTIONS = {
        :host => "saucelabs.com",
        :port => 4444,
        :browser_url => "http://saucelabs.com",
        :os => "Linux",
        :browser => "firefox",
        :browser_version => "3.",
        :job_name => "Unnamed Ruby job",
        :local_application_port => "3001"
    }

    ENVIRONMENT_VARIABLES = %w{SAUCE_HOST SAUCE_PORT SAUCE_BROWSER_URL SAUCE_USERNAME
        SAUCE_ACCESS_KEY SAUCE_OS SAUCE_BROWSER SAUCE_BROWSER_VERSION SAUCE_JOB_NAME
        SAUCE_FIREFOX_PROFILE_URL SAUCE_USER_EXTENSIONS_URL}

    def initialize(opts={})
      @opts = {}
      if opts != false
        @opts.merge! DEFAULT_OPTIONS
        @opts.merge! load_options_from_yaml
        @opts.merge! load_options_from_environment
        @opts.merge! Sauce.get_config.opts rescue {}
        @opts.merge! opts
      end
    end

    def method_missing(meth, *args)
      if meth.to_s =~ /(.*)=$/
        @opts[$1.to_sym] = args[0]
        return args[0]
      elsif meth.to_s =~ /(.*)\?$/
        return @opts[$1.to_sym]
      else
        return @opts[meth]
      end
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

    def browsers
      return @opts[:browsers] if @opts.include? :browsers
      return [[os, browser, browser_version]]
    end

    def domain
      return @opts[:domain] if @opts.include? :domain
      return URI.parse(@opts[:browser_url]).host
    end

    def local?
      return ENV['LOCAL_SELENIUM']
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
            File.join(File.dirname(File.dirname(File.expand_path(File.dirname(__FILE__)))), "ondemand.yml"),
            File.join(File.expand_path("~"), ".sauce", "ondemand.yml")
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
