require "simplecov"

SimpleCov.start do
  SimpleCov.root "#{Dir.pwd}/../../../"
  command_name 'TestUnit Integration'
  use_merging true
  merge_timeout 6000
end

require "rubygems"
require "bundler/setup"
require "test/unit"
require "sauce"