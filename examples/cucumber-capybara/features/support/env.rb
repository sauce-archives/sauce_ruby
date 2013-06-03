require 'capybara/cucumber'
require 'sauce/cucumber'

Sauce.config do |c|
  c[:start_tunnel] = true
end