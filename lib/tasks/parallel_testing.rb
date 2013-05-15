require "sauce/parallel/test_broker"
require "parallel_tests"
require "parallel_tests/tasks"

namespace :sauce do
  task :spec do
    ParallelTests::CLI.new.run(["--type", "saucerspec"] + ["-n #{[20]}", "spec"])
  end
end
