require 'rubygems'
require 'bundler'
require 'rake/testtask'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |s|
    s.pattern = 'spec/sauce/**_spec.rb'
    s.rspec_opts = '-c'
  end

  RSpec::Core::RakeTask.new(:integration) do |s|
    s.pattern = 'spec/integration/**_spec.rb'
    s.rspec_opts = '-c'
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
  gems = Dir["pkg/*.gem"]
  if gems
    system("gem push #{gems[-1]}")
  end
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

#task :default => [:tag, :release, :push]
