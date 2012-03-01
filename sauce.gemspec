# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{sauce}
  s.version = "1.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Eric Allen", "Sean Grove", "Steven Hazel"]
  s.date = %q{2011-04-11}
  s.default_executable = %q{sauce}
  s.description = %q{A Ruby interface to Sauce OnDemand.}
  s.email = %q{help@saucelabs.com}
  s.executables = ["sauce"]
  s.files = [
    "LICENSE",
    "README.markdown",
    "Rakefile",
    "bin/sauce",
    "generators/sauce/sauce_generator.rb",
    "generators/sauce/templates/sauce.rake",
    "lib/generators/sauce/install/install_generator.rb",
    "lib/generators/sauce/install/templates/sauce.rake",
    "lib/sauce.rb",
    "lib/sauce/capybara.rb",
    "lib/sauce/client.rb",
    "lib/sauce/config.rb",
    "lib/sauce/connect.rb",
    "lib/sauce/heroku.rb",
    "lib/sauce/integrations.rb",
    "lib/sauce/job.rb",
    "lib/sauce/raketasks.rb",
    "lib/sauce/selenium.rb",
    "lib/sauce/utilities.rb",
    "sauce.gemspec",
    "support/Sauce-Connect.jar",
    "support/selenium-server.jar",
  ]
  s.homepage = %q{http://github.com/saucelabs/sauce_ruby}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.4.2}
  s.summary = %q{Ruby access to Sauce Labs' features}
  s.test_files = [
    "examples/helper.rb",
    "examples/other_spec.rb",
    "examples/saucelabs_spec.rb",
    "examples/test_saucelabs.rb",
    "examples/test_saucelabs2.rb",
    "test/helper.rb",
    "test/test_config.rb",
    "test/test_connect.rb",
    "test/test_selenium.rb",
    "test/test_job.rb",
    "test/test_selenium2.rb"
  ]

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

