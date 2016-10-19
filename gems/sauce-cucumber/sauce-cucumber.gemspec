# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../lib/sauce/version')

Gem::Specification.new do |gem|
  gem.authors       = ["R. Tyler Croy", "Dylan Lacey"]
  gem.email         = ["tyler@monkeypox.org, dylan@saucelabs.com"]
  gem.description   = 'A Cucumber driver to use Sauce Labs with Cucumber and Capybara.  Supports job naming, job success updates and more!  [DEPRECATED] Sauce Labs does not recommend this gem. It will not receive further development or support.'
  gem.summary       = '[DEPRECATED] Use http://www.saucelabs.com with Cucumber'
  gem.homepage      = 'https://github.com/saucelabs/sauce_ruby/tree/master/gems/sauce-cucumber'
  gem.license       = 'Apache 2.0'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sauce-cucumber"
  gem.require_paths = ["lib"]
  gem.version       = "#{Sauce::MAJOR_VERSION}.0"

  gem.add_dependency('sauce', "~> #{Sauce.version}")
  gem.add_dependency('sauce_whisk', "~>0.0.10")
  gem.add_dependency('cucumber', ['>= 1.2.0', '<2.0.0'])

  gem.post_install_message "WARNING: This gem is no longer supported.  Please see https://wiki.saucelabs.com/display/DOCS/Instant+Selenium+Ruby+Tests for assistance running Ruby tests with Sauce Labs."
end
