require 'json'
require 'yaml'
require 'uri'

module Sauce
  def self.config
    yield get_config
  end

  def self.get_config(default = false)
    get_default = default == :default ? {} : false
    @cfg ||= Sauce::Config.new(get_default)
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
        :job_name => "Unnamed Ruby job",
        :start_tunnel => true,
        :start_local_application => true,
        :warn_on_skipped_integration => true,
        :skip_connection_test => false
    }

    DEFAULT_BROWSERS = {
        :browsers => [
          ["Windows 8", "Internet Explorer", "10"],
          ["Windows 7", "Firefox", "20"],
          ["OS X 10.8", "Safari", "6"],
          ["Linux", "Chrome", nil]
        ]
    }

    POTENTIAL_PORTS = [
        3000, 3001, 3030, 3210, 3333, 4000, 4001, 4040, 4321, 4502, 4503, 5000,
        5001, 5050, 5555, 5432, 6000, 6001, 6060, 6666, 6543, 7000, 7070, 7774,
        7777, 8000, 8001, 8003, 8031, 8080, 8081, 8765, 8888, 9000, 9001, 9080,
        9090, 9876, 9999, 49221, 55001, 80, 443, 888, 2000, 2001, 2020, 2109,
        2222, 2310
    ]

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
      "iexplore" => "internet explorer",
      "ie" => "internet explorer"
    }

    SAUCE_OPTIONS = %w{record-video record-screenshots capture-html tags
        sauce-advisor single-window user-extensions-url firefox-profile-url
        max-duration idle-timeout build custom-data tunnel-identifier
        selenium-version command-timeout prerun prerun-args screen-resolution
        disable-popup-handler avoid-proxy public name iedriver-version}

    def self.get_application_port
      port_index = ENV["TEST_ENV_NUMBER"].to_i
      return POTENTIAL_PORTS[port_index]
    end

    def self.called_from_integrations?
      @called_from_integrations || false
    end

    def self.called_from_integrations
      @called_from_integrations = true
    end

    # Creates a new instance of Sauce::Config
    #
    # @param [Hash, Boolean] opts Any value you'd set with [:option], as a hash.  If false, skip loading default options
    # @option opts [Boolean] :without_defaults Set true to skip loading default values
    #
    # @return [Sauce::Config]
    def initialize(opts={})
      @opts = {}
      @undefaulted_opts = {}
      if opts != false
        if (!opts[:without_defaults]) 
          @opts.merge! DEFAULT_OPTIONS
          @opts.merge! DEFAULT_BROWSERS
          @opts.merge!({:application_port => Sauce::Config.get_application_port})

          @undefaulted_opts.merge! load_options_from_yaml
          @undefaulted_opts.merge! load_options_from_environment
          @undefaulted_opts.merge! load_options_from_heroku unless ENV["SAUCE_DISABLE_HEROKU_CONFIG"]
          
          global_config = Sauce.get_config
          @undefaulted_opts.merge! global_config.opts if global_config.opts
          @whitelisted_capabilities = global_config.whitelisted_capabilities
        end

        @undefaulted_opts.merge! opts
        @opts.merge! @undefaulted_opts
      end
    end

    def [](key)
      @opts[key]
    end

    def []=(key, value)
      if(key == :browsers)
        value = [value] unless value.first.instance_of?(Array)
      end
      @undefaulted_opts.merge!({key => value})
      @opts[key] = value
    end

    def has_key?(key)
      @opts.has_key? key
    end

    def silence_warnings
      false
    end

    def method_missing(meth, *args)
      unless self.silence_warnings
        warn "[DEPRECATED] This method (#{meth}) is deprecated, please use the [] and []= accessors instead"
      end
      if meth.to_s =~ /(.*)=$/
        self[$1.to_sym] = args[0]
        return args[0]
      elsif meth.to_s =~ /(.*)\?$/
        return self[$1.to_sym]
      else
        return self[meth]
      end
    end

    def whitelisted_capabilities
      @whitelisted_capabilities ||= Set.new 
    end

    def whitelist capability
      cap = capability.to_s
      wl = whitelisted_capabilities || Set.new
      @whitelisted_capabilities = wl.add cap
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
      desired_capabilities = {
        :browserName => BROWSERS[browser] || browser,
        :version => browser_version,
        :platform => PLATFORMS[os] || os,
        :name =>@opts[:job_name],
        :client_version => client_version
      }

      allowed_options = whitelisted_capabilities + SAUCE_OPTIONS

      allowed_options.each do |opt|
        [opt, opt.gsub("-", "_")].map(&:to_sym).each do |sym|
          if @opts.include? sym
            desired_capabilities[opt.to_sym] = @opts[sym]
          elsif @opts.include? sym.to_s
            desired_capabilities[opt.to_sym] = @opts[sym.to_s]
          elsif @opts.include?(:caps) && !@opts[:caps].nil?
            if @opts[:caps].include? sym
              desired_capabilities[opt.to_sym] = @opts[:caps][sym]
            elsif @opts[:caps].include? sym.to_s
              desired_capabilities[opt.to_sym] = @opts[:caps][sym.to_s]
            end
          end
        end
      end

      desired_capabilities
    end

    def browsers
      if @undefaulted_opts[:browser]
        # If a specific browser was requested, ignore :browsers and
        # use that one. This allows a setup with :browsers to launch
        # sub-processes pointed just at each browser in the list.
        return [[os, browser, browser_version]]
      end

      return @opts[:browsers] if @opts.include? :browsers
      return [[os, browser, browser_version]]
    end

    def caps_for_location(file, linenumber=nil)
      Sauce::Config.called_from_integrations
      perfile_browsers = @opts[:perfile_browsers]
      
      if perfile_browsers
        platforms = []
        test_location = "#{file}:#{linenumber}"
        if linenumber && (perfile_browsers.include? test_location)
          platforms =  perfile_browsers[test_location]
        else
          platforms = perfile_browsers[file]
        end
        platforms.map { |p| [p['os'], p['browser'], p['version'], (p['caps'] || {})] }
      else
        browsers
      end
    end

    def browser
      if single_browser_set?
        return @undefaulted_opts[:browser]
      end
      if !ENV["TEST_ENV_NUMBER"] && @opts[:browsers]
        @opts[:browsers][0][1]
      else
        raise StandardError, no_browser_message
      end
    end

    def os
      if single_browser_set?
        return @undefaulted_opts[:os]
      end
      if !ENV["TEST_ENV_NUMBER"] && @opts[:browsers]
        @opts[:browsers][0][0]
      else
        @opts[:os]
      end
    end

    def browser_version
      if single_browser_set?
        return @undefaulted_opts[:browser_version] || @undefaulted_opts[:version]
      end
      if !ENV["TEST_ENV_NUMBER"] && @opts[:browsers]
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

    def after_job(hook, &block)
      hooks = @opts[:after_job_hooks] || {}
      hooks[hook] = block unless hooks[hook]
      @opts[:after_job_hooks] = hooks
    end

    def run_post_job_hooks(job_id, platform, job_name, job_success)
      @opts[:after_job_hooks].each do |key, hook|
        hook.call job_id, platform, job_name, job_success
      end
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
            if File.exist? path
                conf = YAML.load_file(path)
                return conf.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
            end
        end
        return {}
    end

    def extract_options_from_hash(env)
      hash = Hash[env]
      opts = {}

      on_demand = hash.delete "SAUCE_ONDEMAND_BROWSERS"
      env_browsers = hash.delete "SAUCE_BROWSERS"
      username = hash.delete("SAUCE_USERNAME") || hash.delete("SAUCE_USER_NAME")
      access_key = hash.delete("SAUCE_ACCESS_KEY") || hash.delete("SAUCE_API_KEY")

      hash.select {|k,v| k.start_with? "SAUCE_"}.each do |k,v|
        opts[k.downcase.sub("sauce_", "").to_sym] = v
      end

      opts[:job_name] = hash['SAUCE_JOB_NAME'] || hash['JOB_NAME']
      opts[:build] = (hash['BUILD_TAG'] ||
                      hash['BUILD_NUMBER'] ||
                      hash['TRAVIS_BUILD_NUMBER'] ||
                      hash['CIRCLE_BUILD_NUM'])

      if hash.include? 'URL'
        opts['SAUCE_BROWSER_URL'] = "http://#{hash['URL']}/"
      end

      if on_demand
        browsers = JSON.parse(on_demand)
        opts[:browsers] = browsers.map { |x| [x['os'], x['browser'], x['browser-version']] }
      end

      if env_browsers
        browsers = JSON.parse(env_browsers)
        opts[:browsers] = browsers.map { |x| [x['os'], x['browser'], x['version'], x['caps']] }
      end

      if hash.include? 'SAUCE_PERFILE_BROWSERS'
        opts[:perfile_browsers] = JSON.parse(hash['SAUCE_PERFILE_BROWSERS'])
      end

      opts[:username] = username if username
      opts[:access_key] = access_key if access_key

      return opts.delete_if {|key, value| value.nil?}
    end

    private

    def single_browser_set?
      @undefaulted_opts[:browser] || @undefaulted_opts[:os] || @undefaulted_opts[:version]
    end

    def no_browser_message
      <<-MESSAGE
No browser has been configured.

It seems you're trying to run your tests in parallel, but haven't configured your specs/tests to use the Sauce integration.

To fix this, add :sauce => true to your specs or make your tests subclasses of Sauce::TestCase or Sauce::RailsTestCase.

For more details check the gem readme at https://github.com/DylanLacey/sauce_ruby/blob/master/README.markdown
      MESSAGE
    end
  end
end
