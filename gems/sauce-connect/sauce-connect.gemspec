# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../lib/sauce/version')
Gem::Specification.new do |gem|
  gem.name          = "sauce-connect"
  gem.version       = "3.6.0"
  gem.authors       = ["R. Tyler Croy", "Steve Hazel", "Dylan Lacey", "Rick Martínez"]
  gem.email         = ["tyler@monkeypox.org"]
  gem.description   = ""
  gem.summary       = ""
  gem.homepage      = ""
  gem.license       = "Apache 2.0"

  gem.files         = Dir['lib/**/*.rb'] + ['support/Sauce-Connect.jar']
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('sauce', "~> #{Sauce::MAJOR_VERSION}")
end
