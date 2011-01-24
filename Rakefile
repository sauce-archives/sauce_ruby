require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sauce"
    gem.summary = "Ruby access to Sauce Labs' features"
    gem.description = "A Ruby interface to Sauce Labs' services. Start/stop tunnels, retrieve Selenium logs, access video replays, etc."
    gem.email = "help@saucelabs.com"
    gem.homepage = "http://github.com/saucelabs/sauce"
    gem.authors = ["Sean Grove", "Eric Allen", "Steven Hazel"]
    gem.add_development_dependency "jeweler", ">= 1.4.0"
    gem.add_runtime_dependency "rest-client", ">= 0"
    gem.add_runtime_dependency "net-ssh", ">= 0"
    gem.add_runtime_dependency "net-ssh-gateway", ">= 0"
    gem.add_runtime_dependency "selenium-webdriver", ">= 0.1.2"
    gem.add_runtime_dependency "childprocess", ">= 0.1.6"
    gem.add_runtime_dependency "json", ">= 1.2.0"
    gem.add_runtime_dependency "cmdparse", ">= 2.0.2"
    gem.add_runtime_dependency "highline", ">= 1.5.0"
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

namespace :test do
  Rake::TestTask.new(:api) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/api/test_*.rb'
    test.verbose = true
  end
  Rake::TestTask.new(:integrations) do |test|
    test.libs << 'lib' << 'test'
    test.pattern = 'test/integrations/test_*.rb'
    test.verbose = true
  end
end

Rake::TestTask.new(:examples) do |test|
  test.libs << 'lib' << 'examples'
  test.pattern = 'examples/test_*.rb'
  test.verbose = true
end

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |test|
    test.libs << 'test'
    test.pattern = 'test/**/test_*.rb'
    test.verbose = true
  end
rescue LoadError
  task :rcov do
    abort "RCov is not available. In order to run rcov, you must: sudo gem install spicycode-rcov"
  end
end

task :test => :check_dependencies

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sauce #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
