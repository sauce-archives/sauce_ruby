require 'jasmine'
require 'rspec/core/rake_task'

namespace :jasmine do
  def run_jasmine_server
    ENV['JASMINE_PORT'] = '3001'
    Jasmine::Config.new.start_jasmine_server
  end

  desc "Execute Jasmine tests in a Chrome browser on Sauce Labs"
  task :sauce do
    run_jasmine_server
    Rake::Task['jasmine:sauce:chrome'].execute
  end

  namespace :sauce do
    desc "Execute Jasmine tests in Chrome, Firefox and Internet Explorer on Sauce Labs"
    task :all do
      run_jasmine_server
      threads = []
      [:firefox, :chrome, :iexplore].each do |browser|
        t = Thread.new do
          Rake::Task["jasmine:sauce:#{browser}"].invoke
        end
        t.abort_on_exception = true
        threads << t
      end

      threads.each do |t|
        t.join
      end
    end

    [[:firefox, 8], [:chrome, nil], [:iexplore, 8]].each do |browser, version|
      desc "Execute Jasmine tests in #{browser}"
      RSpec::Core::RakeTask.new(browser) do |t|
        ENV['SAUCE_BROWSER'] = browser.to_s
        unless version.nil?
          ENV['SAUCE_BROWSER_VERSION'] = version.to_s
        end
        t.rspec_opts = '--color'
        t.pattern = [File.expand_path(File.dirname(__FILE__) + '/runner.rb')]
      end
    end
  end
end

