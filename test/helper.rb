require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'net/telnet'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sauce'

Sauce.config do |config|
  config.browsers = [
    ["Windows 2003", "firefox", "3.6."],
    ["Windows 2003", "safariproxy", "5."]
  ]
  config.browser_url = "http://saucelabs.com"

  #config.application_host = "localhost"
  #config.application_port = "4444"
end
