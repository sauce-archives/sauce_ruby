# -*- encoding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../../lib/sauce/version')

Gem::Specification.new do |gem|
  gem.authors       = ["R. Tyler Croy"]
  gem.email         = ["tyler@monkeypox.org"]
  gem.description   = ''
  gem.summary       = ''
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "sauce-jasmine"
  gem.require_paths = ["lib"]
  gem.version       = "#{Sauce::MAJOR_VERSION}.0"


  gem.add_dependency('sauce', ">= #{Sauce::MAJOR_VERSION}.0")
  gem.add_dependency('jasmine', '~> 1.3')
end
