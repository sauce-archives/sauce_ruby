require "simplecov"

SimpleCov.start do
  SimpleCov.root "#{Dir.pwd}/../../../"
  command_name 'Connect Integration'
  use_merging true
  merge_timeout 6000
end

require "sauce"
require "capybara/rspec"
require "sauce/capybara"

Sauce.config do |c|
  c[:start_tunnel] = true
  c[:warn_on_skipped_integration] = false
  c[:sauce_connect_4_executable] = ENV["SAUCE_CONNECT_4_EXECUTABLE"]
 end

app = proc { |env| [200, {}, ["Hello Sauce!"]]}
Capybara.app = app