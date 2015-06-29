require 'rubygems'
require 'bundler'
require 'rake/testtask'
require 'rspec/core/rake_task'
require 'shellwords'

Bundler::GemHelper.install_tasks

namespace :spec do
  rspec_options = '--color --format d --fail-fast --order random'
  RSpec::Core::RakeTask.new(:unit) do |s|
    s.pattern = 'spec/sauce/**/*_spec.rb'
    s.rspec_opts = rspec_options
  end

  task :integration => [:rspec, :testunit, :connect]

  task :rspec do
    desc "Run an integration test with rspec and capybara"
    ensure_rvm!
    sh "bash --login -c \"cd spec/helpers && ./run_in_own_rvm.sh ./integration/rspec\""
  end

  task :testunit do
    desc "Run an integration test with testunit"
    ensure_rvm!
    sh "bash --login -c \"cd spec/helpers && ./run_in_own_rvm.sh ./integration/testunit\""
  end

  task :connect do
  #  STDERR.puts "Connect spec is busted, and might have been for a while"
    desc "Ensure sauce-connect is starting correctly"
    ensure_rvm!
    sh "bash --login -c \"cd spec/helpers && ./run_in_own_rvm.sh ./integration/connect\""
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
      sh "bash --login -c  \"cd spec/helpers && ./run_in_own_rvm.sh ../examples/cucumber-capybara\""
    end
  end
  namespace :rails3 do
    desc "Run an integration test with the rails3-demo code (slow)"
    task :testunit do |t|
      # ensure_rvm!
      # sh "bash --login -c  \"cd spec/helpers && ./run_in_own_rvm.sh ../examples/rails3-demo\""
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

begin
  require 'rdoc/task'
rescue LoadError
  require 'rake/rdoctask'
end
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sauce #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

GEMS = ['sauce-jasmine', 'sauce-cucumber', 'sauce-connect']

def gem_kind(name)
  name.split('-')[1]
end

GEMS.each do |gem|

  namespace gem_kind(gem) do
    desc "Build the #{gem} gem"
    task :build do
      sh "(cd gems/#{gem} && rake build)"
    end

    desc "Release the #{gem} gem"
    task :release do
      sh "(cd gems/#{gem} && rake release)"
    end
  end
end

task :build => GEMS.collect { |n| "#{gem_kind(n)}:build" }
task :release => [:build]
task :default => [:'spec:unit', :build]
