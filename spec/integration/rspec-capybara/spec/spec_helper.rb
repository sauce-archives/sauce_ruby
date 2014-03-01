require "simplecov"

SimpleCov.start do
  SimpleCov.root "#{Dir.pwd}/../../../"
  command_name 'RSpec Integration'
  use_merging true
  merge_timeout 6000
end

require "rspec"
require "capybara/rspec"
require "sauce"
require "sauce/capybara"

class MyRackApp
  def self.call(env)
    [200, {}, ["Hello"]]
  end
end

Capybara.app = MyRackApp

Sauce.config do |c|
  c[:browsers] = [
      ["Windows 2008", "iexplore", "9"]
  ]

  c[:application_host] = "localhost"
end

def page_deprecation_warning
  return <<-MESSAGE
[DEPRECATED] Using the #page method is deprecated for RSpec tests without Capybara.  Please use the #s or #selenium method instead.
If you are using Capybara and are seeing this message, check the Capybara README for information on how to include the Capybara DSL in your tests.
  MESSAGE
end