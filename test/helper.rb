require 'rubygems'
require 'test/unit'
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

def ensure_rvm_installed
  rvm_executable = File.expand_path("~/.rvm/bin/rvm")
  if File.exist? rvm_executable
    unless defined?(RVM)
      rvm_lib_path = File.expand_path("~/.rvm/lib")
      $LOAD_PATH.unshift(rvm_lib_path) unless $LOAD_PATH.include?(rvm_lib_path)
      require 'rvm'
    end
  else
    raise "You do not have RVM installed. It is required for the integration tests.\n" +
      "Please install it from http://rvm.beginrescueend.com/"
  end
end
