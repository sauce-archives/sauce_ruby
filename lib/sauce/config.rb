require 'json'
require 'yaml'
require 'uri'

module Sauce
  def self.config
    yield get_config
  end

  def self.get_config
    @cfg ||= Sauce::Config.new(false)
  end

  def self.clear_config
    @cfg = nil
  end

  class Config
    attr_reader :opts

    DEFAULT_OPTIONS = {
        :host => "ondemand.saucelabs.com",
        :port => 80,
        :browser_url => "http://saucelabs.com",
        :os => "Windows 2003",
        :browser => "firefox",
        :browser_version => "3.6.",
        :job_name => "Unnamed Ruby job",
        :local_application_port => "3001",
        :capture_traffic => false,
        :start_tunnel => true,
        :start_local_application => true
    }

    ENVIRONMENT_VARIABLES = %w{SAUCE_HOST SAUCE_PORT SAUCE_BROWSER_URL SAUCE_USERNAME
        SAUCE_ACCESS_KEY SAUCE_OS SAUCE_BROWSER SAUCE_BROWSER_VERSION SAUCE_JOB_NAME
        SAUCE_FIREFOX_PROFILE_URL SAUCE_USER_EXTENSIONS_URL
        SAUCE_ONDEMAND_BROWSERS SAUCE_USER_NAME SAUCE_API_KEY}

    PLATFORMS = {
      "Windows 2003" => "WINDOWS",
      "Windows 2008" => "VISTA",
      "Linux" => "LINUX"
    }

    BROWSERS = {
      "iexplore" => "internet explorer"
    }

    SAUCE_OPTIONS = %w{record-video record-screenshots capture-html tags
        sauce-advisor single-window user-extensions-url firefox-profile-url
        max-duration idle-timeout build custom-data}

    def initialize(opts={})
      @opts = {}
      @undefaulted_opts = {}
      if opts != false
        @opts.merge! DEFAULT_OPTIONS

        @undefaulted_opts.merge! load_options_from_yaml
        @undefaulted_opts.merge! load_options_from_environment
        @undefaulted_opts.merge! load_options_from_heroku
        @undefaulted_opts.merge! Sauce.get_config.opts rescue {}
        @undefaulted_opts.merge! opts
        @opts.merge! @undefaulted_opts
      end
    end

    def [](key)
      @opts[key]
    end

    def []=(key, value)
      @opts[key] = value
    end

    def silence_warnings
      false
    end

    def method_missing(meth, *args)
      unless self.silence_warnings
        warn "[DEPRECATED] This method (#{meth}) is deprecated, please use the [] and []= accessors instead"
      end
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
        'os' => os,
        'browser' => browser,
        'browser-version' => browser_version,
        'name' => @opts[:name] || @opts[:job_name]}

      SAUCE_OPTIONS.each do |opt|
        [opt, opt.gsub("-", "_")].map(&:to_sym).each do |sym|
          browser_options[opt] = @opts[sym] if @opts.include? sym
        end
      end
      return browser_options.to_json
    end

    def to_desired_capabilities
      {
        :browserName => BROWSERS[browser] || browser,
        :version => browser_version,
        :platform => PLATFORMS[os] || os,
        :name => @opts[:job_name],
        :client_version => client_version
      }.update(@opts.reject {|k, v| [:browser, :browser_version, :os, :job_name].include? k})
    end

    def browsers
      return @opts[:browsers] if @opts.include? :browsers
      return [[os, browser, browser_version]]
    end

    def browser
      if @undefaulted_opts[:browser]
        return @undefaulted_opts[:browser]
      end
      if @opts[:browsers]
        @opts[:browsers][0][1]
      else
        @opts[:browser]
      end
    end

    def os
      if @undefaulted_opts[:os]
        return @undefaulted_opts[:os]
      end
      if @opts[:browsers]
        @opts[:browsers][0][0]
      else
        @opts[:os]
      end
    end

    def browser_version
      if @undefaulted_opts[:browser_version]
        return @undefaulted_opts[:browser_version]
      end
      if @opts[:browsers]
        @opts[:browsers][0][2]
      else
        @opts[:browser_version]
      end
    end

    def domain
      return @opts[:domain] if @opts.include? :domain
      return URI.parse(@opts[:browser_url]).host
    end

    def local?
      return ENV['LOCAL_SELENIUM']
    end

    def username
      @opts[:username]
    end

    def access_key
      @opts[:access_key]
    end

    def host
      @opts[:host]
    end

    def port
      @opts[:port]
    end

    def tools
      tools = []
      tools << "Rspec" if is_defined? "RSpec"
      tools << "Capybara" if is_defined? "Capybara"
      tools << "Cucumber" if is_defined? "Cucumber"
      tools << "Test::Unit" if is_defined?("Test", "Unit")
      tools
    end

    # Only here to be stubbed for testing.  Gross.
    def is_defined? (top_mod, sub_mod = nil)
      return_value = Object.const_defined? top_mod
      unless !return_value || sub_mod.nil?
        return_value = Object.const_get(top_mod).const_defined? sub_mod
      end

      return_value
    end

    private

    def client_version
      "Ruby: #{RUBY_ENGINE} #{RUBY_VERSION} (#{RUBY_PLATFORM}) Sauce gem: #{Sauce.version} Tools: #{tools.to_s}"
    end

    def load_options_from_environment
      return extract_options_from_hash(ENV)
    end

    # Heroku supports multiple apps per $PWD.  Specify $SAUCE_HEROKU_APP if
    # needed otherwise this can still time out.
    def load_options_from_heroku
      @@heroku_environment ||= begin
        if File.exists?(File.expand_path('~/.heroku'))
          heroku_app = ENV['SAUCE_HEROKU_APP']
          cmd = "heroku config #{heroku_app ? "--app #{heroku_app}": ''}"
          cmd += "--shell 2>/dev/null"
          buffer = IO.popen(cmd) { |out| out.read }
          if $?.exitstatus == 0
            env = {}
            buffer.split("\n").each do |line|
              key, value = line.split("=")
              env[key] = value
            end
            extract_options_from_hash(env)
          else
            {}
          end
        else
          {}
        end
      rescue Errno::ENOENT
        {} # not a Heroku environment
      end
      return @@heroku_environment
    end

    def load_options_from_yaml
        paths = [
            "ondemand.yml",
            File.join("config", "ondemand.yml"),
            File.expand_path("../../../ondemand.yml", __FILE__),
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

    def extract_options_from_hash(env)
      opts = {}
      opts[:host] = env['SAUCE_HOST']
      opts[:port] = env['SAUCE_PORT']
      opts[:browser_url] = env['SAUCE_BROWSER_URL']

      opts[:username] = env['SAUCE_USERNAME'] || env['SAUCE_USER_NAME']
      opts[:access_key] = env['SAUCE_ACCESS_KEY'] || env['SAUCE_API_KEY']

      opts[:os] = env['SAUCE_OS']
      opts[:browser] = env['SAUCE_BROWSER']
      opts[:browser_version] = env['SAUCE_BROWSER_VERSION']
      opts[:job_name] = env['SAUCE_JOB_NAME'] || env['JOB_NAME']

      opts[:firefox_profile_url] = env['SAUCE_FIREFOX_PROFILE_URL']
      opts[:user_extensions_url] = env['SAUCE_USER_EXTENSIONS_URL']

      if env.include? 'URL'
        opts['SAUCE_BROWSER_URL'] = "http://#{env['URL']}/"
      end

      if env.include? 'SAUCE_ONDEMAND_BROWSERS'
        browsers = JSON.parse(env['SAUCE_ONDEMAND_BROWSERS'])
        opts[:browsers] = browsers.map { |x| [x['os'], x['browser'], x['browser-version']] }
      end

      if env.include? 'SAUCE_BROWSERS'
        browsers = JSON.parse(env['SAUCE_BROWSERS'])
        opts[:browsers] = browsers.map { |x| [x['os'], x['browser'], x['version']] }
      end

      return opts.delete_if {|key, value| value.nil?}
    end
  end
end
