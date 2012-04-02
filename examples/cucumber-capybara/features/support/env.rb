
require 'capybara/cucumber'
require 'sauce/capybara'

Capybara.current_driver = :sauce

Sauce.config do |c|
end
