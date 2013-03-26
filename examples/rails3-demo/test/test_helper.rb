ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  fixtures :all

  # Add more helper methods to be used by all tests here...
end

require 'sauce'

Sauce.config do |conf|
    conf.browsers = [
        ["Windows 2003", "firefox", "3.6."]
    ]
    conf.application_host = "127.0.0.1"
    conf.application_port = "3001"
    conf.browser_url = "http://localhost:3001/"
end
