require 'rubygems'
require 'bundler'
require 'rake/testtask'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

namespace :spec do
  rspec_options = '--color --format d --fail-fast --order random'
  RSpec::Core::RakeTask.new(:unit) do |s|
    s.pattern = 'spec/sauce/**_spec.rb'
    s.rspec_opts = rspec_options
  end

  RSpec::Core::RakeTask.new(:integration) do |s|
    s.pattern = 'spec/integration/**_spec.rb'
    s.rspec_opts = rspec_options
  end
end

def ensure_rvm!
  unless File.exists? File.expand_path("~/.rvm/scripts/rvm")
    abort("I don't think you have RVM installed, which means this test will fail")
  end
end

namespace :test do
  namespace :cucumber do
    desc "Run an integration test with the cucumber-capybara code (slow)"
    task :capybara do |t|
      ensure_rvm!
      sh "(cd examples/cucumber-capybara/ && ./run-test.sh)"
    end
  end
  namespace :rails3 do
    desc "Run an integration test with the rails3-demo code (slow)"
    task :testunit do |t|
      ensure_rvm!
      sh "(cd examples/rails3-demo && ./run-test.sh)"
    end
  end
end

desc "Run *all* tests, this will be slow!"
task :test => [:'spec:unit', :'spec:integration',
               :'test:cucumber:capybara', :'test:rails3:testunit']


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

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sauce #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

namespace :jasmine do
  desc 'Build sauce-jasmine gem'
  task :build do
    sh '(cd gems/sauce-jasmine && rake build)'
  end
end

task :build => ['jasmine:build']
task :release => [:build]
task :default => [:'spec:unit', :build]
