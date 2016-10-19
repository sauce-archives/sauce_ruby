# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../lib/sauce/version')
Gem::Specification.new do |gem|
  gem.name          = "sauce-connect"
  gem.version       = "3.6.2"
  gem.authors       = ["R. Tyler Croy", "Steve Hazel", "Dylan Lacey", "Rick Martínez"]
  gem.email         = ["tyler@monkeypox.org"]
  gem.description   = "A wrapper to start and stop a Sauce Connect tunnel programatically.  [DEPRECATED] Sauce Labs does not recommend this gem. It will not receive further development or support."
  gem.summary       = "[DEPRECATED] Manage Sauce Connect from within your tests"
  gem.homepage      = "https://docs.saucelabs.com/reference/sauce-connect"
  gem.license       = "Apache 2.0"

  gem.files         = Dir['lib/**/*.rb']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('sauce', "~> #{Sauce::MAJOR_VERSION}")
  gem.add_development_dependency('rspec', "~>3.3.0")

  gem.post_install_message = <<-ENDLINE
  To use the Sauce Connect gem, you'll need to download the appropriate
  Sauce Connect binary from https://docs.saucelabs.com/reference/sauce-connect

  Then, set the 'sauce_connect_4_executable' key in your Sauce.config block, to
  the path of the unzipped file's /bin/sc.
  ENDLINE

  gem.requirements << 'An account at http://www.saucelabs.com'
  gem.requirements << 'A working copy of Sauce Connect from https://docs.saucelabs.com/reference/sauce-connect'

  gem.post_install_message "WARNING: This gem is no longer supported.  Please see https://wiki.saucelabs.com/display/DOCS/Instant+Selenium+Ruby+Tests for assistance running Ruby tests with Sauce Labs."
end
