require "parallel_tests/cucumber/runner"

module ParallelTests
  module Saucecucumber
    class Runner < ParallelTests::Cucumber::Runner

      def self.run_tests(test_files, process_number, num_processes, options)
        options = options.dup
        sanitized_test_files = test_files.map { |val| Shellwords.escape(val) }
        env = Sauce::TestBroker.next_environment(test_files)
        env.merge!({"AUTOTEST" => "1"}) if $stdout.tty? # display color when we are in a terminal
        options.merge!({:env => env})
        cmd = [
            executable,
            (runtime_logging if File.directory?(File.dirname(runtime_log))),
            cucumber_opts(options[:test_options]),
            *sanitized_test_files
        ].compact.join(" ")
        execute_command(cmd, process_number, num_processes, options)
      end

      def self.tests_in_groups(tests, num_groups, options={})
        originals = (options[:group_by] == :steps) ? Grouper.by_steps(find_tests(tests, options), num_groups, options) : super
        all_tests = originals.flatten * Sauce::TestBroker.test_platforms(:cucumber).length
        base_group_size = all_tests.length / num_groups
        num_full_groups = all_tests.length - (base_group_size * num_groups)

        curpos = 0
        groups = []
        num_groups.times do |i|
          group_size = base_group_size
          if i < num_full_groups
            group_size += 1
          end
          groups << all_tests.slice(curpos, group_size)
          curpos += group_size
        end

        groups
      end
    end
  end
end