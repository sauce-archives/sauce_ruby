require 'sauce'

spec_prereq = File.exist?(File.join(RAILS_ROOT, 'config', 'database.yml')) ? "db:test:prepare" : :noop
task :noop do
end

include Sauce::Utilities

namespace :spec do
  namespace :selenium do
    desc "Run the Selenium acceptance tests in spec/selenium using Sauce OnDemand"
    task :sauce => spec_prereq do
      with_rails_server do
        Rake::Task["spec:selenium:runtests"].invoke
      end
    end

    desc "Run the Selenium acceptance tests in spec/selenium using a local Selenium server"
    task :local => spec_prereq do
      with_rails_server do
        with_selenium_rc do
          Rake::Task["spec:selenium:runtests"].invoke
        end
      end
    end

    desc "" # Hide it from rake -T
    Spec::Rake::SpecTask.new :runtests do |t|
      t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
      t.spec_files = FileList["spec/selenium/**/*_spec.rb"]
    end
  end

  task :selenium => "selenium:sauce"
end

namespace :test do
  namespace :selenium do
    desc "Run the Selenium acceptance tests in test/selenium using Sauce OnDemand"
    task :sauce do
      with_rails_server do
        Rake::Task["test:selenium:runtests"].invoke
      end
    end

    desc "Run the Selenium acceptance tests in spec/selenium using a local Selenium server"
    task :local do
      with_rails_server do
        with_selenium_rc do
          Rake::Task["test:selenium:runtests"].invoke
        end
      end
    end

    Rake::TestTask.new(:runtests) do |t|
      t.libs << "test"
      t.pattern = 'test/selenium/**/*_test.rb'
      t.verbose = true
    end
    # Hide it from rake -T
    Rake::Task['test:selenium:runtests'].instance_variable_set(:@full_comment, nil)
    Rake::Task['test:selenium:runtests'].instance_variable_set(:@comment, nil)
    Rake::Task['test:selenium:runtests'].enhance(["db:test:prepare"])
  end

  task :selenium => "selenium:sauce"
end
