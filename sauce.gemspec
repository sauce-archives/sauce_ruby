
# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sauce/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'sauce'
  s.version = "#{Sauce.version}"
  s.authors = ["Dylan Lacey", "Steven Hazel", "R. Tyler Croy", "Santiago Suarez Ordoñez", "Eric Allen", "Sean Grove"]
  s.homepage = 'http://github.com/sauce-labs/sauce_ruby'
  s.email = 'help@saucelabs.com'
  s.summary = "A Ruby helper for running tests in Sauce Labs"
  s.description = "A Ruby helper for running tests in Sauce Labs' browser testing cloud service"
  # Include pretty much everything in Git except the examples/ directory
  s.files = Dir['lib/**/*.rb'] + Dir['lib/**/**/*.rb']
  s.executables = ['sauce']
  s.default_executable = 'sauce'
  s.require_paths = ["lib"]
  s.test_files = Dir['spec/**/*.rb']

  s.add_development_dependency("capybara", ["~>2.1.0"])

  s.add_dependency('net-http-persistent')
  s.add_dependency('rest-client', [">= 0"])
  s.add_dependency('net-ssh', [">= 0"])
  s.add_dependency('net-ssh-gateway', [">= 0"])
  s.add_dependency('selenium-webdriver', [">= 0.1.2"])
  s.add_dependency('childprocess', [">= 0.1.6"])
  s.add_dependency('json', [">= 1.2.0"])
  s.add_dependency('cmdparse', [">= 2.0.2"])
  s.add_dependency('highline', [">= 1.5.0"])
  s.add_dependency('parallel_tests', ["= 0.12.4"])
end
