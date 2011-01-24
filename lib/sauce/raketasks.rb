require 'sauce'

spec_prereq = File.exist?(File.join(::Rails.root.to_s, 'config', 'database.yml')) ? "db:test:prepare" : :noop
task :noop do
end

class Rake::Task
  def abandon
    @actions.clear
  end
end

include Sauce::Utilities

if defined?(Spec::Rake::SpecTask)
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
        t.spec_opts = ['--options', "\"#{Rails.root.join('spec', 'spec.opts')}\""]
        spec_glob = ENV["SAUCE_SPEC_GLOB"] || "spec/selenium/**/*_spec.rb"
        t.spec_files = FileList[spec_glob]
      end
    end

    task :selenium => "selenium:sauce"
  end

  Rake::Task[:spec].abandon
  desc "Run all specs in spec directory (excluding plugin specs)"
  Spec::Rake::SpecTask.new(:spec => spec_prereq) do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/**/*_spec.rb'].exclude('spec/selenium/*')
  end
end

if defined?(RSpec::Core::RakeTask)
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
      RSpec::Core::RakeTask.new :runtests do |t|
        spec_glob = ENV["SAUCE_SPEC_GLOB"] || "spec/selenium/**/*_spec.rb"
        t.pattern = spec_glob
      end
    end

    task :selenium => "selenium:sauce"
  end
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
      test_glob = ENV["SAUCE_TEST_GLOB"] || "test/selenium/**/*_test.rb"
      t.pattern = test_glob
      t.verbose = true
    end
    # Hide it from rake -T
    Rake::Task['test:selenium:runtests'].instance_variable_set(:@full_comment, nil)
    Rake::Task['test:selenium:runtests'].instance_variable_set(:@comment, nil)
    Rake::Task['test:selenium:runtests'].enhance(["db:test:prepare"])
  end

  task :selenium => "selenium:sauce"
end
