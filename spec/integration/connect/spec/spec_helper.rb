require "sauce"
require "capybara/rspec"
require "sauce/capybara"

Sauce.config do |c|
  c[:start_tunnel] = true
  c[:warn_on_skipped_integration] = false
end