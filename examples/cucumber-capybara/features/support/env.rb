require 'capybara/cucumber'
require 'sauce/cucumber'

Sauce.config do |c|
  c[:start_tunnel] = false
  c[:browser] = "Firefox"
  c[:version] = 21
  c[:os] = "Windows"
end
