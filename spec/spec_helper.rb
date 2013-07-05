require "simplecov"
SimpleCov.start

require "rspec"
$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

['sauce-jasmine', 'sauce-cucumber', 'sauce-connect'].each do |gem|
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../gems/#{gem}/lib"))
end

require 'sauce'
require 'capybara'

RSpec.configure do |c|
  c.filter_run_excluding :capybara_version => lambda { |capybara_version_range|
    actual_version = Gem::Version.new Capybara::VERSION
    lower_bound = Gem::Version.new capybara_version_range[0]
    upper_bound = Gem::Version.new capybara_version_range[1]

    !actual_version.between?(lower_bound, upper_bound)
  }
end
