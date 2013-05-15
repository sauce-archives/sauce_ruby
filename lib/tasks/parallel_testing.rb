require "sauce/parallel/test_broker"
require "parallel_tests"
require "parallel_tests/tasks"

namespace :sauce do
  task :spec do
    concurrency = Sauce::TestBroker.concurrencies
    ParallelTests::CLI.new.run(["--type", "saucerspec"] + ["-n #{concurrency}", "spec"])
  end
end
