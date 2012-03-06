require 'rubygems'
require 'bundler'
require 'rake'
require 'rake/testtask'

Bundler::GemHelper.install_tasks

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
    test.pattern = 'test/test_integrations.rb'
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

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "sauce #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Release gem to rubygems.org'
task :release => :build do
  system "gem push `ls *.gem | sort | tail -n 1`"
end

desc 'tag current version'
task :tag do
  version = nil
  File.open("sauce.gemspec").each do |line|
    if line =~ /s.version = "(.*)"/
      version = $1
    end
  end

  if version.nil?
    raise "Couldn't find version"
  end

  system "git tag v#{version}"
end

desc 'push to github'
task :push do
  system "git push origin master --tags"
end

task :default => [:tag, :release, :push]
