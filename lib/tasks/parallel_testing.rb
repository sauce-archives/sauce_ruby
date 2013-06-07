require "sauce/parallel/test_broker"
require "parallel_tests"
require "parallel_tests/tasks"
require "parallel_tests/cli_patch"

namespace :sauce do
  task :spec, :arg1 do |t, args|

    ::RSpec::Core::Runner.disable_autorun!

    args.with_defaults(:arg1 => [Sauce::TestBroker.concurrencies, 20].min)
    concurrency = args[:arg1]
    ParallelTests::CLI.new.run(["--type", "saucerspec",
                                "-n", "#{concurrency}",
                                "spec"])
  end

  task :features, :files, :concurrency  do |t, args|
    args.with_defaults({
      :concurrency => [Sauce::TestBroker.concurrencies, 20].min,
      :files => "features"
    })
    ParallelTests::CLI.new.run(["--type", "saucecucumber", args[:files],
                                  "-n", args[:concurrency].to_s])
  end

  namespace :install do
    task :features do
      Rake::Task["sauce:install:create_helper"].execute(:helper_type => :features)
      puts <<-ENDLINE
  The Sauce gem is now installed!

  Next steps:

  1.  Edit features/support/sauce_helper.rb with your required platforms
  2.  Set the SAUCE_USERNAME and SAUCE_ACCESS_KEY environment variables
  3.  Run your tests with 'rake sauce:features'

      ENDLINE
    end
    task :spec do
      Rake::Task["sauce:install:create_helper"].execute(:helper_type => :spec)
      spec_helper_path = "spec/spec_helper.rb"
      unless File.open(spec_helper_path) { |f| f.read.match "require \"sauce_helper\""}
        File.open("spec/spec_helper.rb", "a") do |f|
          f.write "require \"sauce_helper\""
        end
      else
        puts "WARNING - The Sauce gem is already integrated into your rspec setup"
      end
      puts <<-ENDLINE
  The Sauce gem is now installed!

  Next steps:

  1.  Edit spec/sauce_helper.rb with your required platforms
  2.  Make sure we've not mangled your spec/spec_helper.rb requiring sauce_helper
  3.  Set the SAUCE_USERNAME and SAUCE_ACCESS_KEY environment variables
  3.  Run your tests with 'rake sauce:spec'

      ENDLINE
    end

    task :create_helper, [:helper_type] do |t, args|
      path = args[:helper_type].to_sym == :features ? "features/support/sauce_helper.rb" : "spec/sauce_helper.rb"
      unless File.exists? path
        File.open(path, "w") do |f|
          f.write (<<-ENDFILE
  # You should edit this file with the browsers you wish to use
  # For options, check out http://saucelabs.com/platforms
  require "sauce"

  Sauce.config do |config|
    config[:browsers] = [
      ["OS", "BROWSER", "VERSION"],
      ["OS", "BROWSER", "VERSION"]
    ]
  end
  ENDFILE
          )
        end
      else
        STDERR.puts "WARNING - sauce_helper has already been created."
      end
    end
  end
end