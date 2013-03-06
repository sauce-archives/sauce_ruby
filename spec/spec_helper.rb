$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')

['sauce-jasmine', 'sauce-cucumber', 'sauce-connect'].each do |gem|
  $LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__) + "/../gems/#{gem}/lib"))
end

require 'sauce'
require 'capybara'

RSpec.configure do |c|
  if Gem::Version.new(Capybara::VERSION) < Gem::Version.new(2)
    c.filter_run_excluding :capy_version => 2
  else
    c.filter_run_excluding :capy_version => 1
  end
end
