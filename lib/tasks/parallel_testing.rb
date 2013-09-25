require "sauce/parallel/test_broker"
require "parallel_tests"
require "parallel_tests/tasks"
require "parallel_tests/cli_patch"

namespace :sauce do
  task :spec, :spec_files, :concurrency, :rspec_options do |t, args|
    ::RSpec::Core::Runner.disable_autorun!

    env_args = {
      :concurrency => ENV['concurrency'],
      :rspec_options => ENV['rspec_options'],
      :spec_files => ENV['specs']
    }

    env_args.delete_if {|k,v| k.nil? || k == ''}

    args.with_defaults({
      :concurrency => [Sauce::TestBroker.concurrency, 20].min,
      :files => "spec",
      :rspec_opts => "-t sauce"
    })

    concurrency = env_args[:concurrency]    || args[:concurrency]
    spec_files = env_args[:spec_files]        || args[:files]
    rspec_options = env_args[:rspec_options]  || args[:rspec_options]

    parallel_arguments = [
      "--type", "saucerspec",
      "-n", "#{concurrency}"
    ]

    unless rspec_options.nil?
      parallel_arguments.push "-o"
      parallel_arguments.push rspec_options
    end

    parallel_arguments.push spec_files

    ParallelTests::CLI.new.run(parallel_arguments)
  end

  task :features, :files, :concurrency  do |t, args|
    args.with_defaults({
      :concurrency => [Sauce::TestBroker.concurrency, 20].min,
      :files => "features"
    })

    env_args = {
      :concurrency => ENV['concurrency'],
      :features => ENV['features']
    }

    env_args.delete_if {|k,v| k.nil? || k == ''}

    concurrency = env_args[:concurrency] || args[:concurrency]
    features = env_args[:features] || args[:files]

    parallel_arguments = [
      "--type", "saucecucumber",
      "-n", concurrency.to_s,
      features
    ]

    STDERR.puts "ARGS #{parallel_arguments}"
    ParallelTests::CLI.new.run(parallel_arguments)
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
          f.write(Sauce::Utilities::Rake.sauce_helper)
        end
      else
        STDERR.puts "WARNING - sauce_helper has already been created."
      end
    end
  end
end
