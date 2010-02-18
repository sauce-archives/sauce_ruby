require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'net/telnet'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'sauce'

class Test::Unit::TestCase
end
