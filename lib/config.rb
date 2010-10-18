require 'json'

module Sauce
  class Config
    attr_reader :opts

    def initialize(opts={})
      @opts = opts
      @opts[:host] ||= ENV['SAUCE_HOST'] || "saucelabs.com"
      @opts[:port] ||= ENV['SAUCE_PORT'] || 4444
      @opts[:browser_url] ||= ENV['SAUCE_BROWSER_URL'] || "http://saucelabs.com"

      @opts[:username] ||= ENV['SAUCE_USERNAME']
      @opts[:access_key] ||= ENV['SAUCE_ACCESS_KEY']

      @opts[:os] ||= ENV['SAUCE_OS'] || "Linux"
      @opts[:browser] ||= ENV['SAUCE_BROWSER'] || "firefox"
      @opts[:browser_version] ||= ENV['SAUCE_BROWSER_VERSION'] || "3."
      @opts[:job_name] ||= ENV['SAUCE_JOB_NAME'] || "Unnamed Ruby job"

      @opts[:firefox_profile_url] ||= ENV['SAUCE_FIREFOX_PROFILE_URL']
      @opts[:user_extensions_url] ||= ENV['SAUCE_USER_EXTENSIONS_URL']
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
  end
end
