# -*- encoding: utf-8 -*-
require File.expand_path('../lib/sauce/version', __FILE__)

Gem::Specification.new do |s|
  s.name = 'sauce'
  s.version = "#{Sauce::MAJOR_VERSION}.0"
  s.authors = ["Eric Allen", "Sean Grove", "Steven Hazel", "R. Tyler Croy", "Santiago Suarez Ordoñez"]
  s.homepage = 'http://github.com/saucelabs/sauce_ruby'
  s.email = 'help@saucelabs.com'
  s.summary = "A Ruby helper for running tests in Sauce OnDemand"
  s.description = "A Ruby helper for running tests in Sauce OnDemand, Sauce Labs' browsers in the cloud service"
  # Include pretty much everything in Git except the examples/ directory
  s.files = `git ls-files`.split("\n").collect { |f| f unless f.include? 'examples' }.compact
  s.executables = ['sauce']
  s.default_executable = 'sauce'
  s.require_paths = ["lib"]
  s.test_files = Dir['test/*.rb']
  s.add_dependency('net-http-persistent')

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<rest-client>, [">= 0"])
      s.add_runtime_dependency(%q<net-ssh>, [">= 0"])
      s.add_runtime_dependency(%q<net-ssh-gateway>, [">= 0"])
      s.add_runtime_dependency(%q<selenium-webdriver>, [">= 0.1.4"])
      s.add_runtime_dependency(%q<childprocess>, [">= 0.1.6"])
      s.add_runtime_dependency(%q<json>, [">= 1.2.0"])
      s.add_runtime_dependency(%q<cmdparse>, [">= 2.0.2"])
      s.add_runtime_dependency(%q<highline>, [">= 1.5.0"])
    else
      s.add_dependency(%q<rest-client>, [">= 0"])
      s.add_dependency(%q<net-ssh>, [">= 0"])
      s.add_dependency(%q<net-ssh-gateway>, [">= 0"])
      s.add_dependency(%q<selenium-webdriver>, [">= 0.1.2"])
      s.add_dependency(%q<childprocess>, [">= 0.1.6"])
      s.add_dependency(%q<json>, [">= 1.2.0"])
      s.add_dependency(%q<cmdparse>, [">= 2.0.2"])
      s.add_dependency(%q<highline>, [">= 1.5.0"])
    end
  else
    s.add_dependency(%q<rest-client>, [">= 0"])
    s.add_dependency(%q<net-ssh>, [">= 0"])
    s.add_dependency(%q<net-ssh-gateway>, [">= 0"])
    s.add_dependency(%q<selenium-webdriver>, [">= 0.1.2"])
    s.add_dependency(%q<childprocess>, [">= 0.1.6"])
    s.add_dependency(%q<json>, [">= 1.2.0"])
    s.add_dependency(%q<cmdparse>, [">= 2.0.2"])
    s.add_dependency(%q<highline>, [">= 1.5.0"])
  end
end
