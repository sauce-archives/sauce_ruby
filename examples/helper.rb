require 'rubygems'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sauce'

Sauce.config do |config|
  config[:browsers] = [
    ["Linux", "firefox", "3.6."]
  ]
  config[:browser_url] = "http://saucelabs.com"
end
